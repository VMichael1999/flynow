import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/core/theme/illustrations.dart';
import 'package:flynow/core/theme/theme.dart';
import 'package:flynow/core/utils/l10n_x.dart';
import 'package:flynow/core/widgets/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_app.dart';

/// Golden tests de los componentes reutilizables de `core/widgets/`.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('es');
  });

  Future<void> gallery(
    WidgetTester t,
    String name,
    double height,
    Widget Function(BuildContext) build,
  ) async {
    t.view.physicalSize = Size(440, height);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Material(
          color: AppColors.background,
          child: Builder(builder: build),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 1200));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/components/$name.png'),
    );
    await t.pumpWidget(const SizedBox());
  }

  const ticket = TicketData(
    airline: 'Garuda Indonesia',
    fromCode: 'DPS',
    fromCity: 'Denpasar',
    toCode: 'CGK',
    toCity: 'Jakarta',
    duration: '1h 50m',
    departure: '06:05',
    arrival: '06:55',
    flightNo: 'GA 159',
    thirdLabel: 'ASIENTOS',
    thirdValue: '30 libres',
    stubDate: 'VIE 4 SEP',
  );

  Widget pad(List<Widget> children) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in children) ...[c, const SizedBox(height: 14)],
      ],
    ),
  );

  testWidgets('botones, chips y selectores', (t) async {
    await gallery(
      t,
      'buttons',
      760,
      (context) => pad([
        const ColoredBox(
          color: AppColors.navy,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                GlassCircleButton(icon: 'i-back', label: 'Volver'),
                SizedBox(width: 12),
                GlassCircleButton(
                  icon: 'i-bell',
                  label: 'Notificaciones',
                  dot: true,
                ),
              ],
            ),
          ),
        ),
        GradientPillButton(
          label: 'Buscar vuelos',
          icon: 'i-search',
          fullWidth: true,
          onTap: () {},
        ),
        const GradientPillButton(label: 'Continuar', fullWidth: true),
        SegmentedPill(
          labels: const ['Solo ida', 'Ida y vuelta', 'Multidestino'],
          selected: 0,
          onChanged: (_) {},
        ),
        SegmentedCards(
          items: const [
            SegmentCard('Próximos', '3 viajes'),
            SegmentCard('Pasados', '2 viajes'),
            SegmentCard('Cancelados', '1 viaje'),
          ],
          selected: 0,
          onChanged: (_) {},
        ),
        const Row(
          children: [
            StatusChip(label: 'Confirmada', icon: 'i-bolt'),
            SizedBox(width: 8),
            StatusChip(label: 'Sale en 13h 20m'),
            SizedBox(width: 8),
            OnTimePill(label: 'A tiempo'),
          ],
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: ChipB(icon: 'i-grid', label: 'Económica'),
        ),
        DayChipRow(
          days: const [
            DayItem('Vie', 4),
            DayItem('Sáb', 5),
            DayItem('Dom', 6),
            DayItem('Lun', 7),
            DayItem('Mar', 8),
          ],
          selected: 0,
          onChanged: (_) {},
        ),
        DateTriplet(
          items: const [
            ('Ayer', 'Mié, 2 sep'),
            ('Hoy', 'Jue, 3 sep'),
            ('Mañana', 'Vie, 4 sep'),
          ],
          selected: 1,
          onChanged: (_) {},
        ),
        const InfoNote(
          text: 'Los asientos estándar están incluidos en Classic.',
        ),
        const ConsentCheckbox(checked: true, label: 'a'),
        const PillSwitch(value: true),
      ]),
    );
  });

  testWidgets('tickets y pase de abordar', (t) async {
    await gallery(
      t,
      'tickets',
      1040,
      (context) => pad([
        FlightTicketCard.result(context, data: ticket, price: r'$113'),
        FlightTicketCard.popular(context, data: ticket, price: r'$52'),
        FlightTicketCard.trip(
          data: ticket,
          booking: const BookingStub(
            code: 'ID-CQ5DU9',
            note: '1 pasajero',
            checkInOpen: true,
          ),
        ),
        const BoardingPassCard(
          data: BoardingPassData(
            airline: 'Batik Air',
            time: '08:15',
            gate: 'B3',
            flightNo: 'ID 157',
            seat: '7D',
            passengerName: 'Michael Dev',
          ),
        ),
      ]),
    );
  });

  testWidgets('pasos, tarifas y resumen', (t) async {
    await gallery(
      t,
      'booking',
      900,
      (context) => Column(
        children: [
          const BookingStepsBar(
            current: 2,
            names: ['Tarifa', 'Pasajeros', 'Asientos', 'Pago'],
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final f in const [
                      FareOption(
                        id: 'l',
                        name: 'Lite',
                        price: r'$110',
                        tag: 'Solo equipaje de mano',
                      ),
                      FareOption(
                        id: 'c',
                        name: 'Classic',
                        price: r'$128',
                        tag: '+ maleta de 20 kg',
                        popular: true,
                      ),
                      FareOption(
                        id: 'x',
                        name: 'Flex',
                        price: r'$152',
                        tag: '+ cambios gratis',
                      ),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FareOptionCard(
                            option: f,
                            selected: f.id == 'c',
                            popularLabel: 'Más elegida',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const IncludesList(
                  title: 'Classic incluye',
                  subtitle: 'Una maleta documentada y eliges tu asiento',
                  rows: [
                    IncludeRow('Equipaje de mano', '7 kg'),
                    IncludeRow(
                      'Maleta documentada',
                      'No incluida',
                      included: false,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const TravellerCard(
                  initials: 'MD',
                  caption: 'Pasajero 1 · Adulto · Tú',
                  name: 'Michael Dev',
                  editLabel: 'Editar',
                  fields: [
                    ('Fecha de nacimiento', '18 mar 1994'),
                    ('Nacionalidad', 'Indonesia'),
                  ],
                ),
                const SizedBox(height: 14),
                const PassengerChip(
                  initials: 'MD',
                  name: 'Michael',
                  seatLabel: 'Asiento 7D',
                ),
              ],
            ),
          ),
          const Spacer(),
          PriceSummaryBar(
            total: r'$137.00',
            caption: '1 pasajero · incl. \$9 de impuestos',
            buttonLabel: 'Continuar',
            onPressed: () {},
          ),
        ],
      ),
    );
  });

  testWidgets('asientos y extras', (t) async {
    await gallery(
      t,
      'seats',
      820,
      (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SeatLegend(
              free: 'Libre',
              chosen: 'Elegido',
              taken: 'Ocupado',
              extra: 'Más espacio',
            ),
            const SizedBox(height: 22),
            SeatMap(
              rows: [
                for (var r = 1; r <= 4; r++)
                  [
                    for (final c in const ['A', 'B', 'C', 'D'])
                      SeatCell(
                        id: '$r$c',
                        column: c,
                        kind:
                            r == 2 && c == 'A'
                                ? SeatKind.taken
                                : r == 3 && c == 'C'
                                ? SeatKind.selected
                                : r == 1
                                ? SeatKind.extra
                                : SeatKind.free,
                        semanticsLabel: 'Asiento $r$c',
                      ),
                  ],
              ],
              exitRows: const {3},
              selectedInitials: 'MD',
              wcLabel: 'WC',
              exitLabel: 'SALIDA',
              onSeatTap: (_) {},
            ),
            const SizedBox(height: 14),
            const ExtraOptionTile(
              icon: 'i-bag',
              name: 'Maleta extra',
              detail: '+1 maleta documentada (máx. 23 kg)',
              price: r'+$18',
              selected: true,
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('pago y resumen de vuelo', (t) async {
    await gallery(
      t,
      'pay',
      1000,
      (context) => pad([
        const FlightSummaryCard(
          route: 'DPS → CGK',
          subtitle: 'Solo ida · 4 sep · Económica Classic',
          yourFlight: 'Tu vuelo · vie, 4 sep',
          fromCode: 'DPS',
          fromTime: '08:50',
          toCode: 'CGK',
          toTime: '09:40',
          duration: '1h 50m',
          airlineLine: 'Batik Air · ID 157',
          seat: '7D',
          initials: 'MD',
          passengerName: 'Michael Dev',
          ticketsTo: 'Boletos a michael.dev@gmail.com',
        ),
        const PaymentMethodCard(
          brandIcon: AppIcon('i-card', size: 22, color: AppColors.primary),
          title: 'Visa •••• 4242',
          expiry: 'Vence 08/29',
          changeLabel: 'Cambiar',
          promoLabel: 'Agregar código promocional',
        ),
        const PriceBreakdownCard(
          title: 'Detalle del precio',
          lines: [
            ('Tarifa Classic', r'$128.00'),
            ('Impuestos y tasas', r'$9.00'),
            ('Asientos', 'Incluido'),
          ],
          totalLabel: 'Total',
          total: r'$137.00',
        ),
      ]),
    );
  });

  testWidgets('cargadores, sello y navegación', (t) async {
    await gallery(
      t,
      'loaders',
      760,
      (context) => pad([
        const Center(child: PlaneOrbitLoader()),
        const Center(child: ConfirmationSeal()),
        const Center(child: SearchingTicketsLoader()),
        const SizedBox(height: 20),
        Center(
          child: GlassNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              NavItem(icon: 'i-home', label: 'Inicio'),
              NavItem(icon: 'i-plane', label: 'Vuelos', filled: true),
              NavItem(icon: 'i-pin', label: 'Estado'),
              NavItem(icon: 'i-user', label: 'Perfil'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ScanFab(label: 'Escanear', onTap: () {}),
        ),
      ]),
    );
  });

  testWidgets('perfil, ajustes y estado', (t) async {
    await gallery(
      t,
      'profile',
      1180,
      (context) => pad([
        const ProfileHeader(
          photo: ProfilePhoto(),
          name: 'Michael Dev',
          email: 'michael.dev@gmail.com',
          homeLine: 'Vuela desde Denpasar · DPS',
          editLabel: 'Editar perfil',
        ),
        const StatsRow(
          stats: [('2', 'Viajes hechos'), ('3', 'Ciudades'), ('3', 'Próximos')],
        ),
        const SettingsGroup(
          label: 'Preferencias',
          children: [
            SettingsTile(
              icon: 'i-bell',
              title: 'Alertas de vuelo',
              switchValue: true,
            ),
            SettingsTile(
              icon: 'i-seat',
              title: 'Asiento preferido',
              value: 'Ventana',
            ),
          ],
        ),
        LogoutButton(label: 'Cerrar sesión', onTap: () {}),
        const FlightStatusCard(
          title: 'GA 159 · Garuda Indonesia',
          dateLabel: 'VIE 4 SEP',
          fromCode: 'DPS',
          fromCity: 'Denpasar',
          toCode: 'CGK',
          toCity: 'Jakarta',
          duration: '1h 50m',
          departure: '06:05',
          arrival: '06:55',
          fields: [('TERMINAL', '1'), ('PUERTA', 'A9'), ('EMBARQUE', '05:30')],
          departsInLabel: 'Sale en',
          departsIn: '10h 35m',
          statusLabel: 'A tiempo',
        ),
        const CompactFlightRow(
          day: 'SÁB',
          route: 'CGK → SUB',
          detail: 'GA 312 · 12 sep · 07:40',
          statusLabel: 'A tiempo',
        ),
        const QuickActionGrid(
          actions: [
            QuickAction(
              icon: 'i-login',
              title: 'Check-in',
              detail: 'Abierto',
              tone: ActionTone.active,
            ),
            QuickAction(
              icon: 'i-scan',
              title: 'Pase de abordar',
              detail: 'Tras el check-in',
              tone: ActionTone.disabled,
            ),
            QuickAction(
              icon: 'i-x',
              title: 'Cancelar',
              detail: 'Pequeño cargo',
              tone: ActionTone.danger,
            ),
          ],
        ),
      ]),
    );
  });

  testWidgets('buscador y barra superior', (t) async {
    await gallery(
      t,
      'search',
      700,
      (context) => Column(
        children: [
          SkyAppBar(
            title: 'Elige tu vuelo',
            leading: BackButtonGlass(() {}),
            trailing: const GlassCircleButton(
              icon: 'i-filter',
              label: 'Filtros',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: SearchCardShell(
              children: [
                SegmentedPill(
                  labels: const ['Solo ida', 'Ida y vuelta', 'Multidestino'],
                  selected: 1,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: AirportBox(
                            label: 'Desde',
                            code: 'DPS',
                            city: 'Denpasar',
                            airport: 'Ngurah Rai',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: AirportBox(
                            label: 'Hacia',
                            code: 'CGK',
                            city: 'Jakarta',
                            airport: 'Soekarno-Hatta',
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    SwapAirportsButton(label: 'Intercambiar', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 10),
                const FieldPairRow(
                  left: FieldCell(
                    icon: 'i-cal',
                    label: 'Ida',
                    value: 'Vie, 4 sep',
                  ),
                  right: FieldCell(
                    icon: 'i-ret',
                    label: 'Vuelta',
                    value: 'Agregar fecha',
                    placeholder: true,
                    trailing: FieldTrailing.plus,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Rutas populares', action: 'Ver todo'),
        ],
      ),
    );
  });
}
