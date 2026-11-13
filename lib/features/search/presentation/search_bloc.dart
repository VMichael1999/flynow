import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../data/airport_catalog.dart';
import '../domain/search_domain.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class TripTypeSelected extends SearchEvent {
  const TripTypeSelected(this.type);
  final TripType type;
  @override
  List<Object?> get props => [type];
}

class AirportsSwapped extends SearchEvent {
  const AirportsSwapped();
}

class DepartureDateSelected extends SearchEvent {
  const DepartureDateSelected(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class PassengersChanged extends SearchEvent {
  const PassengersChanged(this.adults);
  final int adults;
  @override
  List<Object?> get props => [adults];
}

class CabinClassChanged extends SearchEvent {
  const CabinClassChanged(this.cabin);
  final String cabin;
  @override
  List<Object?> get props => [cabin];
}

class OriginSelected extends SearchEvent {
  const OriginSelected(this.airport);
  final Airport airport;
  @override
  List<Object?> get props => [airport];
}

class DestinationSelected extends SearchEvent {
  const DestinationSelected(this.airport);
  final Airport airport;
  @override
  List<Object?> get props => [airport];
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted();
}

class SearchState extends Equatable {
  SearchState({
    this.tripType = TripType.oneWay,
    this.origin = lim,
    this.destination = lax,
    DateTime? departure,
    this.returnDate,
    this.adults = 1,
    this.cabin = 'economy',
    this.searching = false,
    this.submissions = 0,
    this.swapTurns = 0,
  }) : departure = departure ?? kDepartureDate;

  final TripType tripType;
  final Airport origin;
  final Airport destination;
  final DateTime departure;
  final DateTime? returnDate;
  final int adults;
  final String cabin;

  /// Overlay «Buscando vuelos» visible.
  final bool searching;

  /// Se incrementa al terminar cada búsqueda: el `BlocListener` navega con él.
  final int submissions;

  /// Cuántas veces se intercambió (para animar el botón).
  final int swapTurns;

  SearchQuery get query =>
      SearchQuery(origin: origin, destination: destination, date: departure);

  SearchState copyWith({
    TripType? tripType,
    Airport? origin,
    Airport? destination,
    DateTime? departure,
    DateTime? returnDate,
    int? adults,
    String? cabin,
    bool? searching,
    int? submissions,
    int? swapTurns,
  }) => SearchState(
    tripType: tripType ?? this.tripType,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    departure: departure ?? this.departure,
    returnDate: returnDate ?? this.returnDate,
    adults: adults ?? this.adults,
    cabin: cabin ?? this.cabin,
    searching: searching ?? this.searching,
    submissions: submissions ?? this.submissions,
    swapTurns: swapTurns ?? this.swapTurns,
  );

  @override
  List<Object?> get props => [
    tripType,
    origin,
    destination,
    departure,
    returnDate,
    adults,
    cabin,
    searching,
    submissions,
    swapTurns,
  ];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({Duration searchDelay = AppDurations.searching})
    : super(SearchState()) {
    on<TripTypeSelected>((e, emit) => emit(state.copyWith(tripType: e.type)));
    on<AirportsSwapped>(
      (e, emit) => emit(
        state.copyWith(
          origin: state.destination,
          destination: state.origin,
          swapTurns: state.swapTurns + 1,
        ),
      ),
    );
    on<DepartureDateSelected>(
      (e, emit) => emit(state.copyWith(departure: e.date)),
    );
    on<PassengersChanged>((e, emit) => emit(state.copyWith(adults: e.adults)));
    on<CabinClassChanged>((e, emit) => emit(state.copyWith(cabin: e.cabin)));
    // Si se elige la misma ciudad que ya está en el otro extremo, se intercambian.
    on<OriginSelected>(
      (e, emit) => emit(
        e.airport == state.destination
            ? state.copyWith(origin: e.airport, destination: state.origin)
            : state.copyWith(origin: e.airport),
      ),
    );
    on<DestinationSelected>(
      (e, emit) => emit(
        e.airport == state.origin
            ? state.copyWith(destination: e.airport, origin: state.destination)
            : state.copyWith(destination: e.airport),
      ),
    );
    on<SearchSubmitted>((e, emit) async {
      emit(state.copyWith(searching: true));
      await Future<void>.delayed(searchDelay);
      emit(
        state.copyWith(searching: false, submissions: state.submissions + 1),
      );
    });
  }
}
