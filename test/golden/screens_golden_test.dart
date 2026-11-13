import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/app/di.dart';
import 'package:flynow/features/booking/presentation/booking_flow_bloc.dart';
import 'package:flynow/features/booking/presentation/pay_page.dart';
import 'package:flynow/features/search/presentation/search_bloc.dart';
import 'package:flynow/features/search/presentation/search_results_bloc.dart';

import '../helpers/test_app.dart';

/// Golden tests a 440 × 956 de las trece pantallas.
void main() {
  setUpAll(loadAppFonts);

  Future<void> shot(
    WidgetTester t,
    String name,
    String route, {
    Future<void> Function()? before,
    Duration settle = const Duration(seconds: 4),
  }) async {
    await pumpApp(t, route: route);
    if (before != null) await before();
    await t.pump(settle);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
    await disposeApp(t);
  }

  testWidgets(
    'splash',
    (t) => shot(
      t,
      'splash',
      '/splash',
      settle: const Duration(milliseconds: 1500),
    ),
  );
  testWidgets('login', (t) async {
    await shot(
      t,
      'login',
      '/login',
      before: () async {
        // Los logos de Google y Apple se decodifican de forma asíncrona.
        final context = t.element(find.byType(MaterialApp));
        await t.runAsync(() async {
          await precacheImage(
            const AssetImage('assets/images/google_logo.png'),
            context,
          );
          await precacheImage(
            const AssetImage('assets/images/apple_logo.png'),
            context,
          );
        });
        await t.pump();
      },
    );
  });
  testWidgets('home', (t) => shot(t, 'home', '/home'));
  testWidgets('select', (t) async {
    await shot(
      t,
      'select',
      '/select',
      before: () async {
        getIt<SearchResultsBloc>().add(
          SearchResultsRequested(getIt<SearchBloc>().state.query),
        );
        await t.pump(const Duration(milliseconds: 200));
      },
    );
  });
  testWidgets('fare', (t) => shot(t, 'fare', '/book/fare'));
  testWidgets('passengers', (t) => shot(t, 'passengers', '/book/passengers'));
  testWidgets('seats', (t) => shot(t, 'seats', '/book/seats'));
  testWidgets('pay', (t) => shot(t, 'pay', '/book/pay'));
  testWidgets('done', (t) async {
    await shot(
      t,
      'done',
      '/book/pay',
      before: () async {
        final bloc = t.element(find.byType(PayPage)).read<BookingFlowBloc>();
        bloc
          ..add(const SeatToggled('7D'))
          ..add(const ExtraToggled('bag'))
          ..add(const TermsToggled())
          ..add(const PaymentSubmitted());
        await t.pump(const Duration(seconds: 3));
      },
    );
  });
  testWidgets('trip', (t) => shot(t, 'trip', '/trip'));
  testWidgets('flights', (t) => shot(t, 'flights', '/flights'));
  testWidgets('status', (t) => shot(t, 'status', '/status'));
  testWidgets('profile', (t) => shot(t, 'profile', '/profile'));
}
