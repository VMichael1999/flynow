import 'dart:async';

import '../../search/data/airport_catalog.dart';
import '../../search/data/fake_flights_repository.dart';
import '../domain/trips_domain.dart';

/// Viajes semilla (sección 8). Emite cada cambio por un `Stream`.
class FakeTripsRepository implements TripsRepository {
  FakeTripsRepository()
    : _snapshot = TripsSnapshot(
        upcoming: [_next, _roundTrip],
        upcomingTotal: 3,
        pastCount: 2,
        cancelledCount: 1,
      );

  static final _next = Trip(
    reference: 'LA-4F7CMH',
    airline: 'LATAM Airlines',
    flightNo: 'LA 2457',
    from: lim,
    to: mad,
    departure: DateTime(2026, 9, 4, 6, 5),
    arrival: DateTime(2026, 9, 5, 1, 30),
    duration: const Duration(hours: 12, minutes: 25),
    seat: '12A',
    note: '1 pasajero',
    gate: 'A9',
    passengerName: 'Michael Dev',
    checkInOpen: true,
  );

  static final _roundTrip = Trip(
    reference: 'JL-9Z3JRQ',
    airline: 'Japan Airlines',
    flightNo: 'JL 61',
    from: lax,
    to: hnd,
    departure: DateTime(2026, 9, 12, 7, 40),
    arrival: DateTime(2026, 9, 13, 12, 10),
    duration: const Duration(hours: 11, minutes: 30),
    seat: '3F',
    note: 'Ida y vuelta',
    gate: 'C2',
    passengerName: 'Michael Dev',
    dateLabel: '12 – 14 SEP',
  );

  /// Reserva de demostración que muestra «Detalle del viaje» antes de comprar.
  static final demoBooking = () {
    final f = FakeFlightsRepository.defaultFlight;
    return Trip(
      reference: 'ID-CQ5DU9',
      airline: f.airline,
      flightNo: f.flightNo,
      from: f.from,
      to: f.to,
      departure: f.departure,
      arrival: f.arrival,
      duration: f.duration,
      seat: '7D',
      note: '1 pasajero',
      gate: f.gate,
      passengerName: 'Michael Dev',
      checkInOpen: true,
    );
  }();

  TripsSnapshot _snapshot;
  final _controller = StreamController<TripsSnapshot>.broadcast();

  @override
  TripsSnapshot get snapshot => _snapshot;

  @override
  Stream<TripsSnapshot> watch() async* {
    yield _snapshot;
    yield* _controller.stream;
  }

  void _emit(TripsSnapshot s) {
    _snapshot = s;
    _controller.add(s);
  }

  @override
  void add(Trip trip) {
    final list = [..._snapshot.upcoming]..insert(1, trip);
    _emit(
      TripsSnapshot(
        upcoming: list,
        upcomingTotal: _snapshot.upcomingTotal + 1,
        pastCount: _snapshot.pastCount,
        cancelledCount: _snapshot.cancelledCount,
      ),
    );
  }

  @override
  Future<void> checkIn(String reference) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _emit(
      TripsSnapshot(
        upcoming: [
          for (final t in _snapshot.upcoming)
            t.reference == reference ? t.copyWith(checkedIn: true) : t,
        ],
        upcomingTotal: _snapshot.upcomingTotal,
        pastCount: _snapshot.pastCount,
        cancelledCount: _snapshot.cancelledCount,
      ),
    );
  }
}
