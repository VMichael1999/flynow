/// Datos que pinta un [FlightTicketCard]; no depende de ningún BLoC.
class TicketData {
  const TicketData({
    required this.airline,
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.duration,
    required this.departure,
    required this.arrival,
    required this.flightNo,
    required this.thirdLabel,
    required this.thirdValue,
    required this.stubDate,
    this.red = false,
    this.classLabel,
  });

  final String airline;
  final String fromCode;
  final String fromCity;
  final String toCode;
  final String toCity;
  final String duration;
  final String departure;
  final String arrival;
  final String flightNo;

  /// «ASIENTOS» con «30 libres» o «ASIENTO» con «12A».
  final String thirdLabel;
  final String thirdValue;

  /// «VIE 4 SEP» o «12 – 14 SEP».
  final String stubDate;

  /// Cabecera roja (AirAsia).
  final bool red;

  /// Si es nulo se muestra «Económica».
  final String? classLabel;
}

sealed class TicketStub {
  const TicketStub();
}

/// Talón con tarifa: «TARIFA $113 por persona» o «MEJOR TARIFA …».
class FareStub extends TicketStub {
  const FareStub({required this.label, required this.price});
  final String label;
  final String price;
}

/// Talón de reserva: «Check-in abierto», código y nota.
class BookingStub extends TicketStub {
  const BookingStub({
    required this.code,
    required this.note,
    this.checkInOpen = false,
  });
  final String code;
  final String note;
  final bool checkInOpen;
}

/// Datos del pase de abordar.
class BoardingPassData {
  const BoardingPassData({
    required this.airline,
    required this.time,
    required this.gate,
    required this.flightNo,
    required this.seat,
    required this.passengerName,
    this.fromCode = 'LIM',
    this.fromCity = 'Lima',
    this.toCode = 'LAX',
    this.toCity = 'Los Ángeles',
    this.dateLabel = '4 SEP',
  });

  final String airline;
  final String time;
  final String gate;
  final String flightNo;
  final String seat;

  /// Nombre completo del pasajero (se muestra en mayúsculas).
  final String passengerName;

  /// Nombre y apellido para el talón: «MICHAEL DEV».
  String get passengerShort {
    final parts = passengerName.trim().split(RegExp(r'\s+'));
    final short = parts.length <= 2 ? parts : [parts.first, parts.last];
    return short.join(' ').toUpperCase();
  }

  final String fromCode;
  final String fromCity;
  final String toCode;
  final String toCity;
  final String dateLabel;
}
