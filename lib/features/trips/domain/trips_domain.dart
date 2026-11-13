import 'package:equatable/equatable.dart';

import '../../search/domain/search_domain.dart';

/// «Ahora» del prototipo: jueves 3 de septiembre de 2026, 19:30.
final DateTime kNow = DateTime(2026, 9, 3, 19, 30);

class Trip extends Equatable {
  const Trip({
    required this.reference,
    required this.airline,
    required this.flightNo,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.seat,
    required this.note,
    required this.gate,
    required this.passengerName,
    this.dateLabel,
    this.checkInOpen = false,
    this.checkedIn = false,
  });

  final String reference;
  final String airline;
  final String flightNo;
  final Airport from;
  final Airport to;
  final DateTime departure;
  final DateTime arrival;
  final Duration duration;
  final String seat;

  /// «1 pasajero» o «Ida y vuelta».
  final String note;
  final String gate;

  /// Nombre del pasajero tal como va en el pase de abordar.
  final String passengerName;

  /// Fecha del talón cuando no es la de salida («12 – 14 SEP»).
  final String? dateLabel;
  final bool checkInOpen;
  final bool checkedIn;

  /// Embarque 35 minutos antes de la salida.
  DateTime get boarding => departure.subtract(const Duration(minutes: 35));

  /// El check-in cierra una hora antes.
  DateTime get checkInCloses => departure.subtract(const Duration(hours: 1));

  Duration get departsIn => departure.difference(kNow);

  Trip copyWith({bool? checkedIn, String? seat}) => Trip(
    reference: reference,
    airline: airline,
    flightNo: flightNo,
    from: from,
    to: to,
    departure: departure,
    arrival: arrival,
    duration: duration,
    seat: seat ?? this.seat,
    note: note,
    gate: gate,
    passengerName: passengerName,
    dateLabel: dateLabel,
    checkInOpen: checkInOpen,
    checkedIn: checkedIn ?? this.checkedIn,
  );

  @override
  List<Object?> get props => [reference, seat, checkedIn];
}

class TripsSnapshot extends Equatable {
  const TripsSnapshot({
    required this.upcoming,
    required this.upcomingTotal,
    required this.pastCount,
    required this.cancelledCount,
  });

  /// Boletos que se listan en «Próximos».
  final List<Trip> upcoming;

  /// Contador del segmento y del perfil (3, y 4 tras comprar).
  final int upcomingTotal;
  final int pastCount;
  final int cancelledCount;

  @override
  List<Object?> get props => [
    upcoming,
    upcomingTotal,
    pastCount,
    cancelledCount,
  ];
}

abstract interface class TripsRepository {
  TripsSnapshot get snapshot;
  Stream<TripsSnapshot> watch();

  /// Inserta un viaje nuevo en segundo lugar.
  void add(Trip trip);
  Future<void> checkIn(String reference);
}

/// Caso de uso: hacer check-in de un viaje.
class CheckIn {
  const CheckIn(this._repository);
  final TripsRepository _repository;

  Future<void> call(String reference) => _repository.checkIn(reference);
}
