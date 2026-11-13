import 'package:equatable/equatable.dart';

class Airport extends Equatable {
  const Airport({
    required this.code,
    required this.city,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.utcOffset,
  });

  final String code;
  final String city;

  /// Nombre corto del aeropuerto («Jorge Chávez»).
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  /// Diferencia horaria con UTC en septiembre (horario de verano incluido).
  final int utcOffset;

  @override
  List<Object?> get props => [code];
}

class Flight extends Equatable {
  const Flight({
    required this.airline,
    required this.flightNo,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.seatsFree,
    required this.farePrice,
    this.redHeader = false,
    this.gate = 'B3',
  });

  final String airline;
  final String flightNo;
  final Airport from;
  final Airport to;
  final DateTime departure;
  final DateTime arrival;

  /// Duración real del vuelo (las horas son locales de cada aeropuerto).
  final Duration duration;
  final int seatsFree;

  /// Tarifa base por persona, en dólares.
  final int farePrice;

  /// AirAsia lleva la cabecera roja.
  final bool redHeader;
  final String gate;

  @override
  List<Object?> get props => [flightNo, departure];
}

enum TripType { oneWay, roundTrip, multiCity }

class SearchQuery extends Equatable {
  const SearchQuery({
    required this.origin,
    required this.destination,
    required this.date,
  });
  final Airport origin;
  final Airport destination;
  final DateTime date;

  @override
  List<Object?> get props => [origin, destination, date];
}

abstract interface class FlightsRepository {
  /// [refresh] simula volver a pedir las tarifas (con demora realista).
  Future<List<Flight>> search(SearchQuery query, {bool refresh = false});
  Future<List<Flight>> popularRoutes();
}

/// Caso de uso: buscar vuelos para una consulta.
class SearchFlights {
  const SearchFlights(this._repository);
  final FlightsRepository _repository;

  Future<List<Flight>> call(SearchQuery query, {bool refresh = false}) =>
      _repository.search(query, refresh: refresh);
}
