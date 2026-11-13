import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme.dart';
import '../core/utils/l10n_x.dart';
import '../core/widgets/widgets.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/booking/presentation/booking_flow_bloc.dart';
import '../features/booking/presentation/done_page.dart';
import '../features/booking/presentation/fare_page.dart';
import '../features/booking/presentation/passengers_page.dart';
import '../features/booking/presentation/pay_page.dart';
import '../features/booking/presentation/seats_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/search/domain/search_domain.dart';
import '../features/search/presentation/home_page.dart';
import '../features/search/presentation/select_flight_page.dart';
import '../features/status/presentation/flight_status_page.dart';
import '../features/trips/presentation/my_flights_page.dart';
import '../features/trips/domain/trips_domain.dart';
import '../features/trips/presentation/trip_detail_page.dart';
import 'di.dart';

/// Cambio de pantalla: fundido de 350 ms.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.screen,
      reverseTransitionDuration: AppDurations.screen,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        return FadeTransition(opacity: animation, child: child);
      },
    );

GoRoute _route(String path, Widget Function(GoRouterState) builder) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _fade(state, builder(state)),
);

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    _route('/splash', (_) => const SplashPage()),
    _route('/login', (_) => const LoginPage()),
    // Barra inferior y FAB: solo en Inicio, Mis vuelos, Estado y Perfil.
    ShellRoute(
      builder:
          (context, state, child) =>
              _TabShell(location: state.uri.path, child: child),
      routes: [
        _route('/home', (_) => const HomePage()),
        _route('/flights', (_) => const MyFlightsPage()),
        _route('/status', (_) => const FlightStatusPage()),
        _route('/profile', (_) => const ProfilePage()),
      ],
    ),
    _route('/select', (_) => const SelectFlightPage()),
    // Un solo BookingFlowBloc por encima de las cuatro rutas de la compra.
    ShellRoute(
      builder:
          (context, state, child) => BlocProvider(
            create: (_) {
              final bloc = getIt<BookingFlowBloc>();
              final flight = state.extra;
              if (flight is Flight) bloc.add(FlightChosen(flight));
              return bloc;
            },
            child: child,
          ),
      routes: [
        _route('/book/fare', (_) => const FarePage()),
        _route('/book/passengers', (_) => const PassengersPage()),
        _route('/book/seats', (_) => const SeatsPage()),
        _route('/book/pay', (_) => const PayPage()),
        _route('/book/done', (_) => const DonePage()),
      ],
    ),
    _route(
      '/trip',
      (state) => TripDetailPage(
        trip: state.extra is Trip ? state.extra as Trip : null,
      ),
    ),
  ],
);

const _tabs = ['/home', '/flights', '/status', '/profile'];

class _TabShell extends StatelessWidget {
  const _TabShell({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final index = _tabs.indexOf(location).clamp(0, 3);
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 16,
          bottom: 26,
          child: GlassNavBar(
            currentIndex: index,
            onTap: (i) => context.go(_tabs[i]),
            items: [
              NavItem(icon: 'i-home', label: l.navHome),
              NavItem(icon: 'i-plane', label: l.navFlights, filled: true),
              NavItem(icon: 'i-pin', label: l.navStatus),
              NavItem(icon: 'i-user', label: l.navProfile),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 27,
          child: ScanFab(
            label: l.scanLabel,
            onTap: () => getIt<ToastService>().show(l.scanHint),
          ),
        ),
      ],
    );
  }
}
