import 'dart:async';

import '../domain/status_domain.dart';

class FakeStatusRepository implements StatusRepository {
  const FakeStatusRepository();

  static const _next = FlightStatus(
    flightNo: 'LA 2457',
    airline: 'LATAM Airlines',
    dateLabel: 'VIE 4 SEP',
    fromCode: 'LIM',
    fromCity: 'Lima',
    toCode: 'MAD',
    toCity: 'Madrid',
    duration: '12h 25m',
    departure: '06:05',
    arrival: '01:30',
    terminal: '1',
    gate: 'A9',
    boarding: '05:30',
    departsIn: '10h 35m',
    onTime: true,
  );

  static const _board = StatusBoard(
    main: _next,
    upcoming: [
      UpcomingFlight(
        dayLabel: 'SÁB',
        route: 'LAX → HND',
        detail: 'JL 61 · 12 sep · 07:40',
        onTime: true,
      ),
      UpcomingFlight(
        dayLabel: 'LUN',
        route: 'HND → LAX',
        detail: 'JL 62 · 14 sep · 16:15',
        onTime: true,
      ),
    ],
  );

  @override
  Stream<StatusBoard> board() {
    // Tablero en vivo: emite al abrir y vuelve a emitir cada 30 s.
    late final StreamController<StatusBoard> controller;
    Timer? timer;
    controller = StreamController<StatusBoard>(
      onListen: () {
        controller.add(_board);
        timer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => controller.add(_board),
        );
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<FlightStatus> lookup(String flightNo) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _next;
  }
}
