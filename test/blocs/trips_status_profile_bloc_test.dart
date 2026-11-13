import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/features/booking/data/fake_booking_repository.dart';
import 'package:flynow/features/booking/domain/booking_domain.dart';
import 'package:flynow/features/booking/presentation/booking_flow_bloc.dart';
import 'package:flynow/features/profile/presentation/profile_bloc.dart';
import 'package:flynow/features/search/data/fake_flights_repository.dart';
import 'package:flynow/features/status/data/fake_status_repository.dart';
import 'package:flynow/features/status/domain/status_domain.dart';
import 'package:flynow/features/status/presentation/flight_status_bloc.dart';
import 'package:flynow/features/trips/data/fake_trips_repository.dart';
import 'package:flynow/features/trips/domain/trips_domain.dart';
import 'package:flynow/features/trips/presentation/trips_bloc.dart';

void main() {
  group('TripsBloc', () {
    test(
      'la compra nueva entra en segundo lugar y el contador pasa de 3 a 4',
      () async {
        final trips = FakeTripsRepository();
        final bloc = TripsBloc(trips, CheckIn(trips))
          ..add(const TripsStarted());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.upcomingCount, 3);
        expect(bloc.state.snapshot.upcoming.length, 2);

        final repo = FakeBookingRepository(trips, latency: Duration.zero);
        final booking =
            BookingFlowBloc(repo, CreateBooking(repo), payDelay: Duration.zero)
              ..add(const SeatToggled('7D'))
              ..add(const TermsToggled())
              ..add(const PaymentSubmitted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.upcomingCount, 4);
        expect(bloc.state.snapshot.upcoming[1].reference, 'ID-CQ5DU9');
        expect(bloc.state.snapshot.upcoming[1].seat, '7D');
        expect(
          bloc.state.detailTrip.flightNo,
          FakeFlightsRepository.defaultFlight.flightNo,
        );
        await bloc.close();
        await booking.close();
      },
    );

    blocTest<TripsBloc, TripsState>(
      'abrir Pasados avisa de los 2 viajes pasados',
      build: () {
        final trips = FakeTripsRepository();
        return TripsBloc(trips, CheckIn(trips));
      },
      act: (b) => b.add(const TripsTabSelected(TripsTab.past)),
      verify: (b) {
        expect(b.state.notice, TripsNotice.pastTrips);
        expect(b.state.snapshot.pastCount, 2);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'el check-in avisa cuando termina',
      build: () {
        final trips = FakeTripsRepository();
        return TripsBloc(trips, CheckIn(trips));
      },
      act: (b) => b.add(const CheckInRequested('LA-4F7CMH')),
      wait: const Duration(milliseconds: 400),
      verify: (b) => expect(b.state.notice, TripsNotice.checkInDone),
    );
  });

  group('FlightStatusBloc', () {
    blocTest<FlightStatusBloc, FlightStatusState>(
      'escucha el tablero en vivo y reemite',
      build:
          () => FlightStatusBloc(
            const FakeStatusRepository(),
            const GetFlightStatus(FakeStatusRepository()),
          ),
      act: (b) => b.add(const StatusBoardStarted()),
      wait: const Duration(milliseconds: 20),
      verify: (b) {
        expect(b.state.board?.main.flightNo, 'LA 2457');
        expect(b.state.board?.upcoming.length, 2);
      },
    );

    blocTest<FlightStatusBloc, FlightStatusState>(
      'modo, día y consulta',
      build:
          () => FlightStatusBloc(
            const FakeStatusRepository(),
            const GetFlightStatus(FakeStatusRepository()),
          ),
      act:
          (b) =>
              b
                ..add(const StatusModeSelected(StatusMode.byRoute))
                ..add(const StatusDaySelected(2))
                ..add(const StatusChecked()),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.mode, StatusMode.byRoute);
        expect(b.state.dayIndex, 2);
        expect(b.state.checks, 1);
      },
    );
  });

  group('ProfileBloc', () {
    test('Próximos sube a 4 después de comprar', () async {
      final trips = FakeTripsRepository();
      final bloc = ProfileBloc(const FakeProfileRepository(), trips)
        ..add(const ProfileStarted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.upcoming, 3);
      trips.add(FakeTripsRepository.demoBooking);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.upcoming, 4);
      await bloc.close();
    });

    blocTest<ProfileBloc, ProfileState>(
      'alterna las alertas de vuelo',
      build:
          () =>
              ProfileBloc(const FakeProfileRepository(), FakeTripsRepository()),
      act: (b) => b.add(const FlightAlertsToggled()),
      verify: (b) => expect(b.state.flightAlerts, isFalse),
    );
  });
}
