// Herramienta de verificación: vuelca la posición de cada texto de cada pantalla
// para compararla con el HTML (`python3 tool/compare.py`). Uso:
//   flutter test tool/layout_probe_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/app/di.dart';
import 'package:flynow/features/booking/presentation/booking_flow_bloc.dart';
import 'package:flynow/features/booking/presentation/pay_page.dart';
import 'package:flynow/features/search/presentation/search_bloc.dart';
import 'package:flynow/features/search/presentation/search_results_bloc.dart';

import '../test/helpers/test_app.dart';

void main() {
  setUpAll(loadAppFonts);
  final dump = <String, Object>{};
  tearDownAll(() {
    Directory('build/probe').createSync(recursive: true);
    File('build/probe/flutter.json').writeAsStringSync(jsonEncode(dump));
  });

  Future<void> probe(
    WidgetTester t,
    String name,
    String route, {
    Future<void> Function()? before,
  }) async {
    await pumpApp(t, route: route);
    if (before != null) await before();
    await t.pump(const Duration(seconds: 4));
    dump[name] = dumpTexts(t);
    await disposeApp(t);
  }

  testWidgets('login', (t) => probe(t, 'login', '/login'));
  testWidgets('home', (t) => probe(t, 'home', '/home'));
  testWidgets('select', (t) async {
    await probe(
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
  for (final e
      in {
        'fare': '/book/fare',
        'passengers': '/book/passengers',
        'seats': '/book/seats',
        'pay': '/book/pay',
      }.entries) {
    testWidgets(e.key, (t) => probe(t, e.key, e.value));
  }
  testWidgets('done', (t) async {
    await probe(
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
  testWidgets('trip', (t) => probe(t, 'trip', '/trip'));
  testWidgets('flights', (t) => probe(t, 'flights', '/flights'));
  testWidgets('status', (t) => probe(t, 'status', '/status'));
  testWidgets('profile', (t) => probe(t, 'profile', '/profile'));
}
