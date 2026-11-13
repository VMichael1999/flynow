import '../../search/domain/search_domain.dart';
import '../../trips/domain/trips_domain.dart';
import '../domain/booking_domain.dart';

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository(
    this._trips, {
    this.latency = const Duration(milliseconds: 150),
  });

  final TripsRepository _trips;
  final Duration latency;

  static const _taken = {
    '1C',
    '2A',
    '2B',
    '3A',
    '3B',
    '4C',
    '4D',
    '5A',
    '5D',
    '6B',
    '7A',
    '7C',
    '8D',
    '9B', '10A', '10C', '11D', '12B', '13A', '14D', '15B', '16A', '16D', //
  };
  static const _extra = {'1A', '1B', '1D', '8A', '8B', '8C', '9A', '9C', '9D'};

  @override
  List<Fare> faresFor(Flight flight) {
    final base = flight.farePrice;
    return [
      Fare(
        id: 'lite',
        name: 'Lite',
        price: base,
        tag: 'Solo equipaje de mano',
        summary: 'Viaja ligero con equipaje de mano',
        benefits: const [
          FareBenefit('Equipaje de mano', '7 kg'),
          FareBenefit('Maleta documentada', 'No incluida', included: false),
          FareBenefit('Elección de asiento', 'Desde \$8'),
          FareBenefit('Cambios', 'No permitidos', included: false),
          FareBenefit('Cancelación', 'Sin reembolso', included: false),
        ],
      ),
      Fare(
        id: 'classic',
        name: 'Classic',
        price: base + 18,
        tag: '+ maleta de 20 kg',
        summary: 'Una maleta documentada y eliges tu asiento',
        popular: true,
        benefits: const [
          FareBenefit('Equipaje de mano', '7 kg'),
          FareBenefit('Maleta documentada', '20 kg'),
          FareBenefit('Elección de asiento', 'Asientos estándar'),
          FareBenefit('Cambios', '\$45 por cambio'),
          FareBenefit('Cancelación', 'Reembolso menos \$35'),
        ],
      ),
      Fare(
        id: 'flex',
        name: 'Flex',
        price: base + 42,
        tag: '+ cambios gratis',
        summary: 'Cambia o cancela sin estrés',
        benefits: const [
          FareBenefit('Equipaje de mano', '7 kg'),
          FareBenefit('Maleta documentada', '25 kg'),
          FareBenefit('Elección de asiento', 'Cualquier asiento'),
          FareBenefit('Cambios', 'Gratis'),
          FareBenefit('Cancelación', 'Reembolso total'),
        ],
      ),
    ];
  }

  @override
  final List<Extra> extras = const [
    Extra(
      id: 'bag',
      icon: 'i-bag',
      name: 'Maleta extra',
      detail: '+1 maleta documentada (máx. 23 kg)',
      price: 18,
    ),
    Extra(
      id: 'flex',
      icon: 'i-shield',
      name: 'Boleto flexible',
      detail: 'Cambio gratis hasta 3 h antes',
      price: 12,
    ),
    Extra(
      id: 'ins',
      icon: 'i-pulse',
      name: 'Seguro de viaje',
      detail: 'Médico, retrasos y equipaje perdido',
      price: 9,
    ),
  ];

  @override
  final Passenger passenger = Passenger(
    firstName: 'Michael',
    fullName: 'Michael Dev',
    initials: 'MD',
    birthDate: DateTime(1999, 12, 1),
    nationality: 'Peruana',
    passport: '•• 4821',
    passportExpiry: DateTime(2030, 5, 2),
    email: 'michael.dev@gmail.com',
    phone: '+62 812 3456 7890',
  );

  @override
  Seat seat(String id) => Seat(
    id,
    _taken.contains(id)
        ? SeatCategory.taken
        : _extra.contains(id)
        ? SeatCategory.extra
        : SeatCategory.standard,
  );

  @override
  Future<BookingConfirmation> createBooking(Booking booking) async {
    await Future<void>.delayed(latency);
    const reference = 'ID-CQ5DU9';
    final f = booking.flight;
    _trips.add(
      Trip(
        reference: reference,
        airline: f.airline,
        flightNo: f.flightNo,
        from: f.from,
        to: f.to,
        departure: f.departure,
        arrival: f.arrival,
        duration: f.duration,
        seat: booking.seat?.id ?? '—',
        note: '1 pasajero',
        gate: f.gate,
        passengerName: booking.passenger.fullName,
        checkInOpen: true,
      ),
    );
    return BookingConfirmation(reference: reference, total: booking.total);
  }
}
