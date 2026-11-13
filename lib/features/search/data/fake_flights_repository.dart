import 'dart:math' as math;

import '../../../core/utils/formatters.dart';
import '../domain/search_domain.dart';
import 'airport_catalog.dart';

class _Airline {
  const _Airline(this.name, this.code, {this.red = false});
  final String name;
  final String code;
  final bool red;
}

const _airlines = [
  _Airline('LATAM Airlines', 'LA'),
  _Airline('Iberia', 'IB'),
  _Airline('Delta Air Lines', 'DL'),
  _Airline('United Airlines', 'UA'),
  _Airline('Japan Airlines', 'JL'),
  _Airline('All Nippon Airways', 'NH'),
  _Airline('Aeroflot', 'SU', red: true),
  _Airline('Air China', 'CA', red: true),
  _Airline('Aerolíneas Argentinas', 'AR'),
  _Airline('American Airlines', 'AA'),
  _Airline('Avianca', 'AV', red: true),
  _Airline('Air Europa', 'UX'),
];

const _slots = [(6, 5), (8, 50), (11, 20), (13, 15), (16, 40), (19, 55)];

/// Distancia aproximada entre dos aeropuertos, en km (fórmula de haversine).
double distanceKm(Airport a, Airport b) {
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLon = rad(b.longitude - a.longitude);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLon / 2), 2);
  return 6371 * 2 * math.asin(math.sqrt(h));
}

int _seed(Airport a, Airport b) {
  var h = 17;
  for (final c in '${a.code}${b.code}'.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h;
}

/// Genera seis vuelos coherentes con la ruta: duración según la distancia,
/// horas de llegada en la hora local del destino y precio según los km.
List<Flight> generateFlights(Airport from, Airport to, DateTime day) {
  final km = distanceKm(from, to);
  final seed = _seed(from, to);
  final start = seed % _airlines.length;
  final offset = Duration(hours: to.utcOffset - from.utcOffset);
  return [
    for (var i = 0; i < _slots.length; i++)
      () {
        final airline = _airlines[(start + i * 5) % _airlines.length];
        final dep = DateTime(
          day.year,
          day.month,
          day.day,
          _slots[i].$1,
          _slots[i].$2,
        );
        final minutes = (km / 820 * 60 + 35 + (seed + i * 13) % 25).round();
        final duration = Duration(minutes: minutes);
        final price = math.max(
          45,
          (60 + km * 0.028).round() + (seed >> (i * 3)) % 41 - 10,
        );
        return Flight(
          airline: airline.name,
          flightNo: '${airline.code} ${100 + (seed * 7 + i * 131) % 900}',
          from: from,
          to: to,
          departure: dep,
          arrival: dep.add(duration).add(offset),
          duration: duration,
          seatsFree: 8 + (seed + i * 29) % 72,
          farePrice: price,
          redHeader: airline.red,
        );
      }(),
  ];
}

/// Datos de demostración: los vuelos se generan para cualquier par de ciudades.
class FakeFlightsRepository implements FlightsRepository {
  const FakeFlightsRepository({
    this.latency = const Duration(milliseconds: 900),
  });
  final Duration latency;

  /// Ruta que se ve al abrir la app.
  static const defaultOrigin = lim;
  static const defaultDestination = lax;

  /// Vuelo que se usa cuando se abre la compra sin haber elegido uno.
  static Flight get defaultFlight =>
      generateFlights(defaultOrigin, defaultDestination, kDepartureDate)[1];

  @override
  Future<List<Flight>> search(SearchQuery query, {bool refresh = false}) async {
    if (refresh) await Future<void>.delayed(latency);
    return generateFlights(query.origin, query.destination, query.date);
  }

  @override
  Future<List<Flight>> popularRoutes() async => [
    generateFlights(lim, eze, kDepartureDate)[2],
    generateFlights(mad, hnd, DateTime(2026, 9, 5))[3],
  ];
}
