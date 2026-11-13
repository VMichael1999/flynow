import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/features/booking/data/fake_booking_repository.dart';
import 'package:flynow/features/booking/domain/booking_domain.dart';
import 'package:flynow/features/booking/presentation/booking_flow_bloc.dart';
import 'package:flynow/features/search/data/fake_flights_repository.dart';
import 'package:flynow/features/trips/data/fake_trips_repository.dart';

/// Precio base del vuelo por defecto; Classic = base + 18, Flex = base + 42.
final int base = FakeFlightsRepository.defaultFlight.farePrice;
final int classicTotal = base + 18 + 9;

BookingFlowBloc build() {
  final trips = FakeTripsRepository();
  final repo = FakeBookingRepository(trips, latency: Duration.zero);
  return BookingFlowBloc(repo, CreateBooking(repo), payDelay: Duration.zero);
}

void main() {
  group('BookingFlowBloc: total', () {
    test('arranca en Classic: tarifa + 9 de impuestos', () {
      final b = build();
      expect(b.state.total, classicTotal);
      b.close();
    });

    blocTest<BookingFlowBloc, BookingFlowState>(
      'cambiar de tarifa cambia el total (Flex = base + 42 + 9)',
      build: build,
      act: (b) => b.add(const FareSelected('flex')),
      verify: (b) => expect(b.state.total, base + 42 + 9),
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'un asiento con más espacio suma 18; uno estándar no',
      build: build,
      act: (b) => b.add(const SeatToggled('1A')),
      verify: (b) {
        expect(b.state.seatFee, 18);
        expect(b.state.total, classicTotal + 18);
      },
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'asiento 7D estándar + maleta extra suman 18 sobre el total',
      build: build,
      act:
          (b) =>
              b
                ..add(const SeatToggled('7D'))
                ..add(const ExtraToggled('bag')),
      verify: (b) {
        expect(b.state.seat?.id, '7D');
        expect(b.state.total, classicTotal + 18);
      },
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'tocar el asiento elegido lo libera',
      build: build,
      act:
          (b) =>
              b
                ..add(const SeatToggled('7D'))
                ..add(const SeatToggled('7D')),
      verify: (b) => expect(b.state.seat, isNull),
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'un asiento ocupado no se puede elegir',
      build: build,
      act: (b) => b.add(const SeatToggled('2A')),
      expect: () => <BookingFlowState>[],
    );

    blocTest<BookingFlowBloc, BookingFlowState>(
      'los extras suman y restan',
      build: build,
      act:
          (b) =>
              b
                ..add(const ExtraToggled('bag'))
                ..add(const ExtraToggled('flex'))
                ..add(const ExtraToggled('ins'))
                ..add(const ExtraToggled('flex')),
      verify: (b) => expect(b.state.total, classicTotal + 18 + 9),
    );
  });

  group('BookingFlowBloc: pasos', () {
    test('Continuar en asientos está bloqueado sin asiento', () {
      final b = build();
      expect(b.state.canContinueFromSeats, isFalse);
      b.add(const SeatToggled('7D'));
      b.close();
    });

    blocTest<BookingFlowBloc, BookingFlowState>(
      'la leyenda de asientos sale del estado',
      build: build,
      act: (b) => b.add(const SeatToggled('1A')),
      verify: (b) {
        expect(b.state.captionFor(BookingStep.seats), BookingCaption.seatExtra);
        expect(b.state.captionFor(BookingStep.pay), BookingCaption.acceptTerms);
      },
    );
  });

  group('BookingFlowBloc: pago', () {
    blocTest<BookingFlowBloc, BookingFlowState>(
      'pagar sin aceptar los términos no hace nada',
      build: build,
      act: (b) => b.add(const PaymentSubmitted()),
      expect: () => <BookingFlowState>[],
    );

    test('el borrador exige términos aceptados', () {
      final b = build();
      expect(
        () => b.state.draft.build(),
        throwsA(isA<BookingIncompleteException>()),
      );
      b.close();
    });

    blocTest<BookingFlowBloc, BookingFlowState>(
      'pago exitoso: paying y luego paid con la referencia ID-CQ5DU9',
      build: build,
      act:
          (b) =>
              b
                ..add(const TermsToggled())
                ..add(const PaymentSubmitted()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.payment, PaymentStatus.paid);
        expect(b.state.reference, 'ID-CQ5DU9');
      },
      expect:
          () => [
            isA<BookingFlowState>().having(
              (s) => s.termsAccepted,
              'terms',
              true,
            ),
            isA<BookingFlowState>().having(
              (s) => s.payment,
              'pay',
              PaymentStatus.paying,
            ),
            isA<BookingFlowState>()
                .having((s) => s.payment, 'pay', PaymentStatus.paid)
                .having((s) => s.reference, 'ref', 'ID-CQ5DU9'),
          ],
    );
  });
}
