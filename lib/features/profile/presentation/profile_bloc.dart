import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../trips/domain/trips_domain.dart';

class ProfileData extends Equatable {
  const ProfileData({
    required this.name,
    required this.email,
    required this.tripsDone,
    required this.cities,
    required this.savedPassengers,
    required this.paymentMethods,
    required this.documents,
    required this.seatPreference,
    required this.currency,
    this.homeCity = 'Lima',
    this.homeCode = 'LIM',
  });

  final String name;
  final String email;
  final int tripsDone;
  final int cities;
  final int savedPassengers;
  final String paymentMethods;
  final String documents;
  final String seatPreference;
  final String currency;

  /// Aeropuerto base del viajero («Vuela desde Lima · LIM»).
  final String homeCity;
  final String homeCode;

  @override
  List<Object?> get props => [name, email];
}

abstract interface class ProfileRepository {
  ProfileData get profile;
}

class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository();

  @override
  ProfileData get profile => const ProfileData(
    name: 'Michael Dev',
    email: 'michael.dev@gmail.com',
    tripsDone: 2,
    cities: 3,
    savedPassengers: 3,
    paymentMethods: '2 tarjetas',
    documents: 'Vigentes',
    seatPreference: 'Ventana',
    currency: 'USD',
  );
}

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileUpcomingChanged extends ProfileEvent {
  const ProfileUpcomingChanged(this.count);
  final int count;
  @override
  List<Object?> get props => [count];
}

class FlightAlertsToggled extends ProfileEvent {
  const FlightAlertsToggled();
}

class ProfileState extends Equatable {
  const ProfileState({
    required this.data,
    required this.upcoming,
    this.flightAlerts = true,
  });

  final ProfileData data;
  final int upcoming;
  final bool flightAlerts;

  ProfileState copyWith({int? upcoming, bool? flightAlerts}) => ProfileState(
    data: data,
    upcoming: upcoming ?? this.upcoming,
    flightAlerts: flightAlerts ?? this.flightAlerts,
  );

  @override
  List<Object?> get props => [data, upcoming, flightAlerts];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(ProfileRepository profiles, this._trips)
    : super(
        ProfileState(
          data: profiles.profile,
          upcoming: _trips.snapshot.upcomingTotal,
        ),
      ) {
    on<ProfileStarted>((e, emit) {
      _sub ??= _trips.watch().listen(
        (s) => add(ProfileUpcomingChanged(s.upcomingTotal)),
      );
    });
    on<ProfileUpcomingChanged>(
      (e, emit) => emit(state.copyWith(upcoming: e.count)),
    );
    on<FlightAlertsToggled>(
      (e, emit) => emit(state.copyWith(flightAlerts: !state.flightAlerts)),
    );
  }

  final TripsRepository _trips;
  StreamSubscription<TripsSnapshot>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
