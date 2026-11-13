import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/app/di.dart';
import 'package:flynow/app/router.dart';
import 'package:flynow/core/utils/formatters.dart';
import 'package:flynow/core/widgets/widgets.dart';
import 'package:flynow/features/search/data/fake_flights_repository.dart';
import 'package:flynow/features/trips/presentation/trips_bloc.dart';

import 'helpers/test_app.dart';

/// Criterio de aceptación 3: el flujo de punta a punta.
void main() {
  setUpAll(loadAppFonts);

  final flight = FakeFlightsRepository.defaultFlight;
  final classic = flight.farePrice + 18 + 9; // Classic + impuestos

  /// Una pasada para construir la ruta y otra para terminar el fundido de 350 ms.
  Future<void> settle(WidgetTester t, [int ms = 450]) async {
    await t.pump();
    await t.pump(Duration(milliseconds: ms));
  }

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text).first;
    await t.ensureVisible(f);
    await t.pump();
    await t.tap(f, warnIfMissed: false);
    await t.pump();
  }

  testWidgets(
    'Splash → Login → Inicio → compra → Detalle → Mis vuelos → Perfil',
    (t) async {
      await pumpApp(t, route: '/splash');
      appRouter.go('/login');
      await settle(t, 500);

      // Login: overlay de 1.8 s y luego Inicio.
      await tapText(t, 'Iniciar sesión');
      await settle(t, 500);
      expect(find.text('Iniciando sesión'), findsOneWidget);
      await settle(t, 1800);
      await settle(t, 500);
      expect(find.text('¿A dónde vas?'), findsOneWidget);

      // Intercambio de aeropuertos.
      expect(find.text('LIM'), findsWidgets);
      await t.tap(
        find.bySemanticsLabel('Intercambiar aeropuertos').first,
        warnIfMissed: false,
      );
      await t.pump();
      final codes = [
        for (final e in find.byType(AirportBox).evaluate())
          (e.widget as AirportBox).code,
      ];
      expect(codes, ['LAX', 'LIM']);
      await t.tap(find.byType(SwapAirportsButton));
      await settle(t, 400);

      // Buscar vuelos → overlay 1.7 s → Elige tu vuelo.
      await tapText(t, 'Buscar vuelos');
      await settle(t, 600);
      expect(find.text('Buscando vuelos'), findsOneWidget);
      await settle(t, 1800);
      await settle(t, 500);
      expect(find.text('Elige tu vuelo'), findsOneWidget);
      expect(find.text('6 aerolíneas'), findsOneWidget);

      // Vuelo por defecto (segundo de la lista) → Tarifa (Classic por defecto).
      await t.tap(find.text(flight.airline).first);
      await settle(t, 600);
      expect(find.text('Elige tu tarifa'), findsOneWidget);
      expect(find.text(Money.format(classic)), findsOneWidget);
      await tapText(t, 'Continuar');
      await settle(t, 500);

      // Pasajeros → Asientos.
      expect(find.text('¿Quién viaja?'), findsOneWidget);
      await tapText(t, 'Continuar');
      await settle(t, 500);

      // Asiento 7D + maleta extra: el total sube 18 con la maleta.
      expect(find.text('Sin asiento'), findsOneWidget);
      final seat = find.byWidgetPredicate(
        (w) => w is SeatButton && w.semanticsLabel == 'Asiento 7D',
      );
      await t.ensureVisible(seat);
      await t.pump();
      // Lleva el asiento al centro para que no lo tape la barra de resumen.
      await t.drag(
        find.byType(SingleChildScrollView).first,
        Offset(0, 450 - t.getCenter(seat).dy),
      );
      await t.pump();
      await t.tap(seat);
      await t.pump();
      expect(find.text('Asiento 7D'), findsOneWidget);
      await tapText(t, 'Maleta extra');
      expect(find.text(Money.format(classic + 18)), findsWidgets);
      await tapText(t, 'Continuar');
      await settle(t, 500);

      // Revisa y paga: «Pagar» está bloqueado hasta aceptar los términos.
      expect(find.text('Acepta los términos para pagar'), findsOneWidget);
      final pay = find.text('Pagar ${Money.format(classic + 18)}');
      expect(pay, findsOneWidget);
      final terms = find.byType(ConsentCheckbox);
      await t.ensureVisible(terms);
      await t.pump();
      await t.drag(
        find.byType(SingleChildScrollView).first,
        Offset(0, 450 - t.getCenter(terms).dy),
      );
      await t.pump();
      await t.tap(terms);
      await t.pump();
      expect(find.text('1 pasajero · incl. impuestos y tasas'), findsOneWidget);
      await t.tap(pay);
      await settle(t, 600);
      expect(find.text('Confirmando tu reserva'), findsOneWidget);
      await settle(t, 1900);
      await settle(t, 600);
      await t.pump(const Duration(seconds: 2));
      expect(find.text('Reserva confirmada'), findsOneWidget);
      expect(find.text('ID-CQ5DU9'), findsOneWidget);

      // Detalle del viaje → Mis vuelos (Próximos 4).
      await tapText(t, 'Ver viaje');
      await settle(t, 600);
      expect(find.text('Detalle del viaje'), findsOneWidget);
      appRouter.go('/flights');
      await settle(t, 600);
      expect(find.text('4 viajes'), findsOneWidget);
      expect(
        getIt<TripsBloc>().state.snapshot.upcoming[1].reference,
        'ID-CQ5DU9',
      );

      // Estado de vuelos y Perfil (Próximos 4).
      appRouter.go('/status');
      await settle(t, 600);
      expect(find.text('Tablero en vivo'), findsOneWidget);
      appRouter.go('/profile');
      await settle(t, 600);
      expect(find.text('Próximos'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      await disposeApp(t);
    },
  );

  testWidgets('Mis vuelos: al tocar un viaje se abre su detalle', (t) async {
    await pumpApp(t, route: '/flights');
    await t.pump(const Duration(milliseconds: 500));
    // Segundo viaje de la lista: LAX → HND (JL 61).
    final stub = find.text('JL-9Z3JRQ');
    await t.ensureVisible(stub);
    await t.pump();
    await t.drag(
      find.byType(SingleChildScrollView).first,
      Offset(0, 400 - t.getCenter(stub).dy),
    );
    await t.pump();
    await t.tap(stub);
    await settle(t);
    expect(find.text('Detalle del viaje'), findsOneWidget);
    expect(find.text('JL 61'), findsWidgets);
    expect(find.text('LAX'), findsWidgets);
    await disposeApp(t);
  });
}
