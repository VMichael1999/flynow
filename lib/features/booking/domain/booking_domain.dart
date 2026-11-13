import 'package:equatable/equatable.dart';

import '../../search/domain/search_domain.dart';

/// Impuestos y tasas fijos por pasajero.
const int kTaxes = 9;

/// Cargo por un asiento con más espacio.
const int kExtraSeatFee = 18;

class FareBenefit extends Equatable {
  const FareBenefit(this.label, this.value, {this.included = true});
  final String label;
  final String value;
  final bool included;

  @override
  List<Object?> get props => [label, value, included];
}

class Fare extends Equatable {
  const Fare({
    required this.id,
    required this.name,
    required this.price,
    required this.tag,
    required this.summary,
    required this.benefits,
    this.popular = false,
  });

  final String id;
  final String name;
  final int price;
  final String tag;
  final String summary;
  final List<FareBenefit> benefits;
  final bool popular;

  @override
  List<Object?> get props => [id];
}

class Extra extends Equatable {
  const Extra({
    required this.id,
    required this.icon,
    required this.name,
    required this.detail,
    required this.price,
  });
  final String id;
  final String icon;
  final String name;
  final String detail;
  final int price;

  @override
  List<Object?> get props => [id];
}

enum SeatCategory { standard, taken, extra }

class Seat extends Equatable {
  const Seat(this.id, this.category);
  final String id;
  final SeatCategory category;

  int get fee => category == SeatCategory.extra ? kExtraSeatFee : 0;

  @override
  List<Object?> get props => [id, category];
}

class Passenger extends Equatable {
  const Passenger({
    required this.firstName,
    required this.fullName,
    required this.initials,
    required this.birthDate,
    required this.nationality,
    required this.passport,
    required this.passportExpiry,
    required this.email,
    required this.phone,
  });

  final String firstName;
  final String fullName;
  final String initials;
  final DateTime birthDate;
  final String nationality;
  final String passport;
  final DateTime passportExpiry;
  final String email;
  final String phone;

  Passenger copyWith({String? email, String? phone}) => Passenger(
    firstName: firstName,
    fullName: fullName,
    initials: initials,
    birthDate: birthDate,
    nationality: nationality,
    passport: passport,
    passportExpiry: passportExpiry,
    email: email ?? this.email,
    phone: phone ?? this.phone,
  );

  @override
  List<Object?> get props => [fullName, email, phone];
}

class BookingIncompleteException implements Exception {
  const BookingIncompleteException(this.missing);
  final String missing;

  @override
  String toString() => 'Reserva incompleta: falta $missing';
}

/// Reserva validada, lista para cobrar.
class Booking extends Equatable {
  const Booking({
    required this.flight,
    required this.fare,
    required this.passenger,
    required this.seat,
    required this.extras,
    required this.total,
  });
  final Flight flight;
  final Fare fare;
  final Passenger passenger;
  final Seat? seat;
  final List<Extra> extras;
  final int total;

  @override
  List<Object?> get props => [flight, fare, passenger, seat, extras, total];
}

/// Builder: se arma paso a paso y `build()` valida tarifa, pasajero y términos.
class BookingDraft {
  Flight? _flight;
  Fare? _fare;
  Passenger? _passenger;
  Seat? _seat;
  final List<Extra> _extras = [];
  bool _terms = false;

  BookingDraft flight(Flight? v) => this.._flight = v;
  BookingDraft fare(Fare? v) => this.._fare = v;
  BookingDraft passenger(Passenger? v) => this.._passenger = v;
  BookingDraft seat(Seat? v) => this.._seat = v;
  BookingDraft extras(Iterable<Extra> v) {
    _extras
      ..clear()
      ..addAll(v);
    return this;
  }

  BookingDraft termsAccepted(bool v) => this.._terms = v;

  Booking build() {
    final flight = _flight;
    final fare = _fare;
    final passenger = _passenger;
    if (flight == null) throw const BookingIncompleteException('el vuelo');
    if (fare == null) throw const BookingIncompleteException('la tarifa');
    if (passenger == null) {
      throw const BookingIncompleteException('el pasajero');
    }
    if (!_terms) throw const BookingIncompleteException('aceptar los términos');
    final total =
        fare.price +
        kTaxes +
        (_seat?.fee ?? 0) +
        _extras.fold<int>(0, (a, e) => a + e.price);
    return Booking(
      flight: flight,
      fare: fare,
      passenger: passenger,
      seat: _seat,
      extras: List.unmodifiable(_extras),
      total: total,
    );
  }
}

class BookingConfirmation extends Equatable {
  const BookingConfirmation({required this.reference, required this.total});
  final String reference;
  final int total;

  @override
  List<Object?> get props => [reference, total];
}

abstract interface class BookingRepository {
  /// Tarifas del vuelo: Lite al precio base y Classic/Flex con recargo.
  List<Fare> faresFor(Flight flight);
  List<Extra> get extras;
  Passenger get passenger;
  Seat seat(String id);
  Future<BookingConfirmation> createBooking(Booking booking);
}

/// Caso de uso: cobrar y registrar la reserva.
class CreateBooking {
  const CreateBooking(this._repository);
  final BookingRepository _repository;

  Future<BookingConfirmation> call(Booking booking) =>
      _repository.createBooking(booking);
}
