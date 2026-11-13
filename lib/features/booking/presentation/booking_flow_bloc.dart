import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../search/data/fake_flights_repository.dart';
import '../../search/domain/search_domain.dart';
import '../domain/booking_domain.dart';

/// Leyenda de la barra de resumen; la pantalla la traduce con `intl`.
enum BookingCaption {
  fareWithTaxes,
  passengerFare,
  chooseSeat,
  seatFree,
  seatExtra,
  acceptTerms,
  payIncluded,
}

enum BookingStep { fare, passengers, seats, pay }

enum PaymentStatus { idle, paying, paid }

sealed class BookingFlowEvent extends Equatable {
  const BookingFlowEvent();
  @override
  List<Object?> get props => [];
}

class FlightChosen extends BookingFlowEvent {
  const FlightChosen(this.flight);
  final Flight flight;
  @override
  List<Object?> get props => [flight];
}

class FareSelected extends BookingFlowEvent {
  const FareSelected(this.fareId);
  final String fareId;
  @override
  List<Object?> get props => [fareId];
}

class PassengerUpdated extends BookingFlowEvent {
  const PassengerUpdated(this.passenger);
  final Passenger passenger;
  @override
  List<Object?> get props => [passenger];
}

class SeatToggled extends BookingFlowEvent {
  const SeatToggled(this.seatId);
  final String seatId;
  @override
  List<Object?> get props => [seatId];
}

class ExtraToggled extends BookingFlowEvent {
  const ExtraToggled(this.extraId);
  final String extraId;
  @override
  List<Object?> get props => [extraId];
}

class TermsToggled extends BookingFlowEvent {
  const TermsToggled();
}

class PaymentSubmitted extends BookingFlowEvent {
  const PaymentSubmitted();
}

class BookingFlowState extends Equatable {
  const BookingFlowState({
    required this.flight,
    required this.fare,
    required this.passenger,
    this.seat,
    this.extras = const [],
    this.termsAccepted = false,
    this.payment = PaymentStatus.idle,
    this.reference,
  });

  final Flight flight;
  final Fare fare;
  final Passenger passenger;
  final Seat? seat;
  final List<Extra> extras;
  final bool termsAccepted;
  final PaymentStatus payment;
  final String? reference;

  int get seatFee => seat?.fee ?? 0;
  int get extrasTotal => extras.fold(0, (a, e) => a + e.price);

  /// El total nunca se guarda: tarifa + impuestos + asiento + extras.
  int get total => fare.price + kTaxes + seatFee + extrasTotal;

  bool hasExtra(String id) => extras.any((e) => e.id == id);

  bool get canContinueFromSeats => seat != null;
  bool get canPay => termsAccepted && payment == PaymentStatus.idle;

  /// Leyenda de la barra de resumen en cada paso.
  BookingCaption captionFor(BookingStep step) => switch (step) {
    BookingStep.fare => BookingCaption.fareWithTaxes,
    BookingStep.passengers => BookingCaption.passengerFare,
    BookingStep.seats =>
      seat == null
          ? BookingCaption.chooseSeat
          : (seatFee > 0 ? BookingCaption.seatExtra : BookingCaption.seatFree),
    BookingStep.pay =>
      termsAccepted ? BookingCaption.payIncluded : BookingCaption.acceptTerms,
  };

  /// Borrador del builder con el estado actual.
  BookingDraft get draft =>
      BookingDraft()
        ..flight(flight)
        ..fare(fare)
        ..passenger(passenger)
        ..seat(seat)
        ..extras(extras)
        ..termsAccepted(termsAccepted);

  BookingFlowState copyWith({
    Flight? flight,
    Fare? fare,
    Passenger? passenger,
    Seat? Function()? seat,
    List<Extra>? extras,
    bool? termsAccepted,
    PaymentStatus? payment,
    String? reference,
  }) => BookingFlowState(
    flight: flight ?? this.flight,
    fare: fare ?? this.fare,
    passenger: passenger ?? this.passenger,
    seat: seat != null ? seat() : this.seat,
    extras: extras ?? this.extras,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    payment: payment ?? this.payment,
    reference: reference ?? this.reference,
  );

  @override
  List<Object?> get props => [
    flight,
    fare,
    passenger,
    seat,
    extras,
    termsAccepted,
    payment,
    reference,
  ];
}

class BookingFlowBloc extends Bloc<BookingFlowEvent, BookingFlowState> {
  BookingFlowBloc(
    this._repository,
    this._createBooking, {
    Duration payDelay = AppDurations.paying,
  }) : super(
         BookingFlowState(
           flight: FakeFlightsRepository.defaultFlight,
           fare: _repository.faresFor(FakeFlightsRepository.defaultFlight)[1],
           passenger: _repository.passenger,
         ),
       ) {
    on<FlightChosen>((e, emit) {
      // Al cambiar de vuelo se conserva la tarifa elegida, con el precio del nuevo vuelo.
      final fare = _repository
          .faresFor(e.flight)
          .firstWhere((f) => f.id == state.fare.id);
      emit(state.copyWith(flight: e.flight, fare: fare));
    });
    on<FareSelected>((e, emit) {
      final fare = _repository
          .faresFor(state.flight)
          .firstWhere((f) => f.id == e.fareId);
      emit(state.copyWith(fare: fare));
    });
    on<PassengerUpdated>(
      (e, emit) => emit(state.copyWith(passenger: e.passenger)),
    );
    on<SeatToggled>((e, emit) {
      final seat = _repository.seat(e.seatId);
      if (seat.category == SeatCategory.taken) return;
      emit(state.copyWith(seat: () => state.seat?.id == seat.id ? null : seat));
    });
    on<ExtraToggled>((e, emit) {
      final extra = _repository.extras.firstWhere((x) => x.id == e.extraId);
      final next =
          state.hasExtra(extra.id)
              ? state.extras.where((x) => x.id != extra.id).toList()
              : [...state.extras, extra];
      emit(state.copyWith(extras: next));
    });
    on<TermsToggled>(
      (e, emit) => emit(state.copyWith(termsAccepted: !state.termsAccepted)),
    );
    on<PaymentSubmitted>((e, emit) async {
      if (!state.canPay) return;
      final booking = state.draft.build();
      emit(state.copyWith(payment: PaymentStatus.paying));
      await Future<void>.delayed(payDelay);
      final result = await _createBooking(booking);
      emit(
        state.copyWith(
          payment: PaymentStatus.paid,
          reference: result.reference,
        ),
      );
    });
  }

  final BookingRepository _repository;
  final CreateBooking _createBooking;

  /// Catálogo de la cabina (ocupado, más espacio o estándar).
  Seat seatAt(String id) => _repository.seat(id);

  /// Tarifas del vuelo elegido.
  List<Fare> faresFor(Flight flight) => _repository.faresFor(flight);
  List<Extra> get extraCatalog => _repository.extras;
}
