import 'package:equatable/equatable.dart';

class FlightStatus extends Equatable {
  const FlightStatus({
    required this.flightNo,
    required this.airline,
    required this.dateLabel,
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.duration,
    required this.departure,
    required this.arrival,
    required this.terminal,
    required this.gate,
    required this.boarding,
    required this.departsIn,
    required this.onTime,
  });

  final String flightNo;
  final String airline;
  final String dateLabel;
  final String fromCode;
  final String fromCity;
  final String toCode;
  final String toCity;
  final String duration;
  final String departure;
  final String arrival;
  final String terminal;
  final String gate;
  final String boarding;
  final String departsIn;
  final bool onTime;

  @override
  List<Object?> get props => [flightNo, dateLabel, onTime];
}

class UpcomingFlight extends Equatable {
  const UpcomingFlight({
    required this.dayLabel,
    required this.route,
    required this.detail,
    required this.onTime,
  });
  final String dayLabel;
  final String route;
  final String detail;
  final bool onTime;

  @override
  List<Object?> get props => [route, detail];
}

class StatusBoard extends Equatable {
  const StatusBoard({required this.main, required this.upcoming});
  final FlightStatus main;
  final List<UpcomingFlight> upcoming;

  @override
  List<Object?> get props => [main, upcoming];
}

abstract interface class StatusRepository {
  /// Tablero en vivo: emite al abrir y cada vez que cambia.
  Stream<StatusBoard> board();
  Future<FlightStatus> lookup(String flightNo);
}

/// Caso de uso: consultar el estado de un vuelo.
class GetFlightStatus {
  const GetFlightStatus(this._repository);
  final StatusRepository _repository;

  Future<FlightStatus> call(String flightNo) => _repository.lookup(flightNo);
}
