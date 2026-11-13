import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/core/widgets/widgets.dart';
import 'package:flynow/features/search/presentation/ticket_mappers.dart';
import 'package:flynow/features/trips/data/fake_trips_repository.dart';

BoardingPassData pass(String name) => BoardingPassData(
  airline: 'LATAM Airlines',
  time: '05:30',
  gate: 'A9',
  flightNo: 'LA 2457',
  seat: '12A',
  passengerName: name,
);

void main() {
  test('el pase toma el nombre del pasajero de la reserva', () {
    final trip = FakeTripsRepository().snapshot.upcoming.first;
    expect(boardingPassFromTrip(trip).passengerName, trip.passengerName);
  });

  test('el talón muestra nombre y apellido en mayúsculas', () {
    expect(pass('Michael Dev').passengerShort, 'MICHAEL DEV');
    expect(pass('Juan Carlos Pérez Gómez').passengerShort, 'JUAN GÓMEZ');
    expect(pass('Ana').passengerShort, 'ANA');
  });
}
