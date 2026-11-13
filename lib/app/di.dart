import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/presentation/login_bloc.dart';
import '../features/booking/data/fake_booking_repository.dart';
import '../features/booking/domain/booking_domain.dart';
import '../features/booking/presentation/booking_flow_bloc.dart';
import '../features/profile/presentation/profile_bloc.dart';
import '../features/search/data/fake_flights_repository.dart';
import '../features/search/domain/search_domain.dart';
import '../features/search/presentation/search_bloc.dart';
import '../features/search/presentation/search_results_bloc.dart';
import '../features/status/data/fake_status_repository.dart';
import '../features/status/domain/status_domain.dart';
import '../features/status/presentation/flight_status_bloc.dart';
import '../features/trips/data/fake_trips_repository.dart';
import '../features/trips/domain/trips_domain.dart';
import '../features/trips/presentation/trips_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Aviso emergente global (toast) que vive sobre todas las pantallas.
class ToastService extends ChangeNotifier {
  String message = '';
  bool visible = false;
  int _token = 0;

  Future<void> show(
    String text, {
    Duration duration = const Duration(milliseconds: 2400),
  }) async {
    message = text;
    visible = true;
    notifyListeners();
    final mine = ++_token;
    await Future<void>.delayed(duration);
    if (mine == _token) {
      visible = false;
      notifyListeners();
    }
  }
}

Future<void> setupDi() async {
  await getIt.reset();
  getIt
    // Repositorios (implementaciones falsas con los datos de la sección 8).
    ..registerLazySingleton<TripsRepository>(FakeTripsRepository.new)
    ..registerLazySingleton<FlightsRepository>(
      () => const FakeFlightsRepository(),
    )
    ..registerLazySingleton<BookingRepository>(
      () => FakeBookingRepository(getIt()),
    )
    ..registerLazySingleton<StatusRepository>(
      () => const FakeStatusRepository(),
    )
    ..registerLazySingleton<AuthRepository>(() => const FakeAuthRepository())
    ..registerLazySingleton<ProfileRepository>(
      () => const FakeProfileRepository(),
    )
    // Casos de uso.
    ..registerFactory(() => SearchFlights(getIt()))
    ..registerFactory(() => CreateBooking(getIt()))
    ..registerFactory(() => CheckIn(getIt()))
    ..registerFactory(() => GetFlightStatus(getIt()))
    // BLoCs de vida larga (toda la sesión).
    ..registerLazySingleton(SearchBloc.new, dispose: (b) => b.close())
    ..registerLazySingleton(
      () => SearchResultsBloc(getIt()),
      dispose: (b) => b.close(),
    )
    ..registerLazySingleton(
      () => TripsBloc(getIt(), getIt())..add(const TripsStarted()),
      dispose: (b) => b.close(),
    )
    ..registerLazySingleton(
      () => ProfileBloc(getIt(), getIt())..add(const ProfileStarted()),
      dispose: (b) => b.close(),
    )
    ..registerLazySingleton(
      () => FlightStatusBloc(getIt(), getIt())..add(const StatusBoardStarted()),
      dispose: (b) => b.close(),
    )
    // BLoCs por pantalla / flujo.
    ..registerFactory(() => LoginBloc(getIt()))
    ..registerFactory(() => BookingFlowBloc(getIt(), getIt()))
    ..registerLazySingleton(ToastService.new);
}
