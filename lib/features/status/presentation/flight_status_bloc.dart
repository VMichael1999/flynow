import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/status_domain.dart';

enum StatusMode { byNumber, byRoute }

sealed class FlightStatusEvent extends Equatable {
  const FlightStatusEvent();
  @override
  List<Object?> get props => [];
}

class StatusBoardStarted extends FlightStatusEvent {
  const StatusBoardStarted();
}

class StatusBoardUpdated extends FlightStatusEvent {
  const StatusBoardUpdated(this.board);
  final StatusBoard board;
  @override
  List<Object?> get props => [board];
}

class StatusModeSelected extends FlightStatusEvent {
  const StatusModeSelected(this.mode);
  final StatusMode mode;
  @override
  List<Object?> get props => [mode];
}

/// Ayer (0), Hoy (1) o Mañana (2).
class StatusDaySelected extends FlightStatusEvent {
  const StatusDaySelected(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class StatusQueryChanged extends FlightStatusEvent {
  const StatusQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class StatusChecked extends FlightStatusEvent {
  const StatusChecked();
}

class FlightStatusState extends Equatable {
  const FlightStatusState({
    this.board,
    this.mode = StatusMode.byNumber,
    this.dayIndex = 1,
    this.query = '',
    this.checks = 0,
    this.updates = 0,
  });

  final StatusBoard? board;
  final StatusMode mode;
  final int dayIndex;
  final String query;

  /// Veces que se pulsó «Consultar estado» (dispara el aviso).
  final int checks;

  /// Veces que el tablero en vivo emitió.
  final int updates;

  FlightStatusState copyWith({
    StatusBoard? board,
    StatusMode? mode,
    int? dayIndex,
    String? query,
    int? checks,
    int? updates,
  }) => FlightStatusState(
    board: board ?? this.board,
    mode: mode ?? this.mode,
    dayIndex: dayIndex ?? this.dayIndex,
    query: query ?? this.query,
    checks: checks ?? this.checks,
    updates: updates ?? this.updates,
  );

  @override
  List<Object?> get props => [board, mode, dayIndex, query, checks, updates];
}

class FlightStatusBloc extends Bloc<FlightStatusEvent, FlightStatusState> {
  FlightStatusBloc(this._repository, this._getStatus)
    : super(const FlightStatusState()) {
    on<StatusBoardStarted>((e, emit) {
      // Observer: escucha el flujo del tablero en vivo.
      _sub ??= _repository.board().listen((b) => add(StatusBoardUpdated(b)));
    });
    on<StatusBoardUpdated>(
      (e, emit) =>
          emit(state.copyWith(board: e.board, updates: state.updates + 1)),
    );
    on<StatusModeSelected>((e, emit) => emit(state.copyWith(mode: e.mode)));
    on<StatusDaySelected>((e, emit) => emit(state.copyWith(dayIndex: e.index)));
    on<StatusQueryChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<StatusChecked>((e, emit) async {
      await _getStatus(state.query.isEmpty ? 'GA 159' : state.query);
      emit(state.copyWith(checks: state.checks + 1));
    });
  }

  final StatusRepository _repository;
  final GetFlightStatus _getStatus;
  StreamSubscription<StatusBoard>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
