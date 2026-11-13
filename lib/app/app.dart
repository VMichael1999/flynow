import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/theme.dart';
import '../core/utils/l10n_x.dart';
import '../core/widgets/widgets.dart';
import '../features/profile/presentation/profile_bloc.dart';
import '../features/search/presentation/search_bloc.dart';
import '../features/search/presentation/search_results_bloc.dart';
import '../features/status/presentation/flight_status_bloc.dart';
import '../features/trips/presentation/trips_bloc.dart';
import 'di.dart';
import 'router.dart';

class FlyNowApp extends StatelessWidget {
  const FlyNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SearchBloc>()),
        BlocProvider.value(value: getIt<SearchResultsBloc>()),
        BlocProvider.value(value: getIt<TripsBloc>()),
        BlocProvider.value(value: getIt<ProfileBloc>()),
        BlocProvider.value(value: getIt<FlightStatusBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'FlyNow',
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: appRouter,
        builder:
            (context, child) => MultiBlocListener(
              listeners: [
                BlocListener<TripsBloc, TripsState>(
                  listenWhen:
                      (a, b) =>
                          a.noticeId != b.noticeId &&
                          b.notice != TripsNotice.none,
                  listener: (context, s) {
                    final l = context.l10n;
                    final message = switch (s.notice) {
                      TripsNotice.pastTrips => l.pastToast,
                      TripsNotice.cancelledTrip => l.cancelledToast,
                      TripsNotice.checkInDone => l.checkInDone,
                      TripsNotice.none => '',
                    };
                    getIt<ToastService>().show(message);
                  },
                ),
                BlocListener<FlightStatusBloc, FlightStatusState>(
                  listenWhen: (a, b) => a.checks != b.checks,
                  listener:
                      (context, _) =>
                          getIt<ToastService>().show(context.l10n.statusToast),
                ),
              ],
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    Positioned.fill(child: child ?? const SizedBox.shrink()),
                    const _ToastHost(),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost();

  @override
  Widget build(BuildContext context) {
    final toast = getIt<ToastService>();
    return ListenableBuilder(
      listenable: toast,
      builder:
          (_, __) => AppToast(message: toast.message, visible: toast.visible),
    );
  }
}
