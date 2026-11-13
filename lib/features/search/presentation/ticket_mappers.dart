import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../../trips/domain/trips_domain.dart';
import '../domain/search_domain.dart';

/// Vuelo de búsqueda o ruta popular → datos del boleto.
TicketData ticketFromFlight(Flight f, AppL10n l, {DateTime? stubDate}) =>
    TicketData(
      airline: f.airline,
      fromCode: f.from.code,
      fromCity: f.from.city,
      toCode: f.to.code,
      toCity: f.to.city,
      duration: Fmt.duration(f.duration),
      departure: Fmt.time(f.departure),
      arrival: Fmt.time(f.arrival),
      flightNo: f.flightNo,
      thirdLabel: l.labelSeats,
      thirdValue: l.freeSeats(f.seatsFree),
      stubDate: Fmt.stubDate(stubDate ?? f.departure),
      red: f.redHeader,
    );

/// Reserva del usuario → datos del boleto (tercera columna: ASIENTO).
TicketData ticketFromTrip(Trip t, AppL10n l) => TicketData(
  airline: t.airline,
  fromCode: t.from.code,
  fromCity: t.from.city,
  toCode: t.to.code,
  toCity: t.to.city,
  duration: Fmt.duration(t.duration),
  departure: Fmt.time(t.departure),
  arrival: Fmt.time(t.arrival),
  flightNo: t.flightNo,
  thirdLabel: l.labelSeat,
  thirdValue: t.seat,
  stubDate: t.dateLabel ?? Fmt.stubDate(t.departure),
);

BoardingPassData boardingPassFromTrip(Trip t) => BoardingPassData(
  airline: t.airline,
  time: Fmt.time(t.boarding),
  gate: t.gate,
  flightNo: t.flightNo,
  seat: t.seat,
  passengerName: t.passengerName,
  fromCode: t.from.code,
  fromCity: t.from.city,
  toCode: t.to.code,
  toCity: t.to.city,
  dateLabel: '${t.departure.day} ${Fmt.monthShort(t.departure).toUpperCase()}',
);
