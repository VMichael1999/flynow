import '../domain/search_domain.dart';

/// Aeropuertos de demostración.
const lim = Airport(
  code: 'LIM',
  city: 'Lima',
  name: 'Jorge Chávez',
  country: 'Perú',
  latitude: -12.02,
  longitude: -77.11,
  utcOffset: -5,
);
const lax = Airport(
  code: 'LAX',
  city: 'Los Ángeles',
  name: 'Intl. de Los Ángeles',
  country: 'Estados Unidos',
  latitude: 33.94,
  longitude: -118.41,
  utcOffset: -7,
);
const hnd = Airport(
  code: 'HND',
  city: 'Tokio',
  name: 'Haneda',
  country: 'Japón',
  latitude: 35.55,
  longitude: 139.78,
  utcOffset: 9,
);
const eze = Airport(
  code: 'EZE',
  city: 'Buenos Aires',
  name: 'Ezeiza',
  country: 'Argentina',
  latitude: -34.82,
  longitude: -58.54,
  utcOffset: -3,
);
const mad = Airport(
  code: 'MAD',
  city: 'Madrid',
  name: 'Barajas',
  country: 'España',
  latitude: 40.47,
  longitude: -3.56,
  utcOffset: 2,
);
const svo = Airport(
  code: 'SVO',
  city: 'Moscú',
  name: 'Sheremétievo',
  country: 'Rusia',
  latitude: 55.97,
  longitude: 37.41,
  utcOffset: 3,
);
const pek = Airport(
  code: 'PEK',
  city: 'Pekín',
  name: 'Capital',
  country: 'China',
  latitude: 40.08,
  longitude: 116.58,
  utcOffset: 8,
);

/// Ciudades que se pueden elegir como origen o destino.
const kAirports = [lim, lax, hnd, eze, mad, svo, pek];
