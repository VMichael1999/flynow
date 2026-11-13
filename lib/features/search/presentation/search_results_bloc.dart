import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/search_domain.dart';

sealed class SearchResultsEvent extends Equatable {
  const SearchResultsEvent();
  @override
  List<Object?> get props => [];
}

class SearchResultsRequested extends SearchResultsEvent {
  const SearchResultsRequested(this.query);
  final SearchQuery query;
  @override
  List<Object?> get props => [query];
}

/// Pull-to-refresh: vuelve a pedir las tarifas.
class SearchResultsRefreshed extends SearchResultsEvent {
  const SearchResultsRefreshed();
}

class SearchResultsDaySelected extends SearchResultsEvent {
  const SearchResultsDaySelected(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

enum ResultsStatus { loading, loaded }

class SearchResultsState extends Equatable {
  const SearchResultsState({
    this.status = ResultsStatus.loading,
    this.flights = const [],
    this.dayIndex = 0,
    this.refreshes = 0,
    this.query,
  });

  final ResultsStatus status;
  final List<Flight> flights;
  final int dayIndex;

  /// Cuántas veces se refrescó (la pantalla reinicia el avión y avisa).
  final int refreshes;
  final SearchQuery? query;

  SearchResultsState copyWith({
    ResultsStatus? status,
    List<Flight>? flights,
    int? dayIndex,
    int? refreshes,
    SearchQuery? query,
  }) => SearchResultsState(
    status: status ?? this.status,
    flights: flights ?? this.flights,
    dayIndex: dayIndex ?? this.dayIndex,
    refreshes: refreshes ?? this.refreshes,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => [status, flights, dayIndex, refreshes, query];
}

class SearchResultsBloc extends Bloc<SearchResultsEvent, SearchResultsState> {
  SearchResultsBloc(this._searchFlights) : super(const SearchResultsState()) {
    on<SearchResultsRequested>((e, emit) async {
      emit(state.copyWith(status: ResultsStatus.loading, query: e.query));
      final flights = await _searchFlights(e.query);
      emit(state.copyWith(status: ResultsStatus.loaded, flights: flights));
    });
    on<SearchResultsRefreshed>((e, emit) async {
      final q = state.query;
      if (q == null) return;
      final flights = await _searchFlights(q, refresh: true);
      emit(state.copyWith(flights: flights, refreshes: state.refreshes + 1));
    });
    on<SearchResultsDaySelected>(
      (e, emit) => emit(state.copyWith(dayIndex: e.index)),
    );
  }

  final SearchFlights _searchFlights;
}
