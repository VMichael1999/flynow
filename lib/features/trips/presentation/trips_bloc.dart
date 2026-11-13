import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_trips_repository.dart';
import '../domain/trips_domain.dart';

enum TripsTab { upcoming, past, cancelled }

/// Aviso de una sola vez para la pantalla (toast).
enum TripsNotice { none, pastTrips, cancelledTrip, checkInDone }

sealed class TripsEvent extends Equatable {
  const TripsEvent();
  @override
  List<Object?> get props => [];
}

class TripsStarted extends TripsEvent {
  const TripsStarted();
}

class TripsSnapshotReceived extends TripsEvent {
  const TripsSnapshotReceived(this.snapshot);
  final TripsSnapshot snapshot;
  @override
  List<Object?> get props => [snapshot];
}

class TripsTabSelected extends TripsEvent {
  const TripsTabSelected(this.tab);
  final TripsTab tab;
  @override
  List<Object?> get props => [tab];
}

class CheckInRequested extends TripsEvent {
  const CheckInRequested(this.reference);
  final String reference;
  @override
  List<Object?> get props => [reference];
}

class TripsState extends Equatable {
  const TripsState({
    required this.snapshot,
    this.tab = TripsTab.upcoming,
    this.notice = TripsNotice.none,
    this.noticeId = 0,
  });

  final TripsSnapshot snapshot;
  final TripsTab tab;
  final TripsNotice notice;

  /// Identifica cada aviso, aunque se repita el mismo tipo.
  final int noticeId;

  Trip get nextTrip => snapshot.upcoming.first;
  int get upcomingCount => snapshot.upcomingTotal;

  /// Viaje que abre «Detalle del viaje»: la compra más reciente o la demo.
  Trip get detailTrip => snapshot.upcoming.firstWhere(
    (t) => t.reference == FakeTripsRepository.demoBooking.reference,
    orElse: () => FakeTripsRepository.demoBooking,
  );

  TripsState copyWith({
    TripsSnapshot? snapshot,
    TripsTab? tab,
    TripsNotice? notice,
    int? noticeId,
  }) => TripsState(
    snapshot: snapshot ?? this.snapshot,
    tab: tab ?? this.tab,
    notice: notice ?? this.notice,
    noticeId: noticeId ?? this.noticeId,
  );

  @override
  List<Object?> get props => [snapshot, tab, notice, noticeId];
}

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc(this._repository, this._checkIn)
    : super(TripsState(snapshot: _repository.snapshot)) {
    on<TripsStarted>((e, emit) {
      _sub ??= _repository.watch().listen((s) => add(TripsSnapshotReceived(s)));
    });
    on<TripsSnapshotReceived>(
      (e, emit) => emit(state.copyWith(snapshot: e.snapshot)),
    );
    on<TripsTabSelected>((e, emit) {
      final notice = switch (e.tab) {
        TripsTab.past => TripsNotice.pastTrips,
        TripsTab.cancelled => TripsNotice.cancelledTrip,
        TripsTab.upcoming => TripsNotice.none,
      };
      emit(
        state.copyWith(
          tab: e.tab,
          notice: notice,
          noticeId: state.noticeId + 1,
        ),
      );
    });
    on<CheckInRequested>((e, emit) async {
      await _checkIn(e.reference);
      emit(
        state.copyWith(
          notice: TripsNotice.checkInDone,
          noticeId: state.noticeId + 1,
        ),
      );
    });
  }

  final TripsRepository _repository;
  final CheckIn _checkIn;
  StreamSubscription<TripsSnapshot>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
