import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/search_domain.dart';
import 'airport_picker.dart';
import 'search_bloc.dart';
import 'search_results_bloc.dart';
import 'ticket_mappers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Flight>> _popular =
      getIt<FlightsRepository>().popularRoutes();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<SearchBloc, SearchState>(
      listenWhen: (a, b) => b.submissions != a.submissions,
      listener: (context, state) {
        context.read<SearchResultsBloc>().add(
          SearchResultsRequested(state.query),
        );
        context.go('/select');
      },
      builder: (context, state) {
        final bloc = context.read<SearchBloc>();
        return ScreenFrame(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 210,
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 300,
                          maxHeight: 300,
                          child: _Header(
                            greeting: l.greeting,
                            title: l.whereTo,
                            bellLabel: l.notifications,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _SearchCard(state: state, bloc: bloc),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 28, bottom: 14),
                        child: SectionHeader(
                          title: l.popularRoutes,
                          action: l.seeAll,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: FutureBuilder<List<Flight>>(
                          future: _popular,
                          builder: (context, snap) {
                            final flights = snap.data ?? const <Flight>[];
                            return Column(
                              children: [
                                for (var i = 0; i < flights.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 14),
                                  FlightTicketCard.popular(
                                    context,
                                    data: ticketFromFlight(flights[i], l),
                                    price: Money.whole(flights[i].farePrice),
                                    onTap: () {
                                      // La ruta popular se convierte en la búsqueda actual.
                                      final f = flights[i];
                                      context.read<SearchResultsBloc>().add(
                                        SearchResultsRequested(
                                          SearchQuery(
                                            origin: f.from,
                                            destination: f.to,
                                            date: f.departure,
                                          ),
                                        ),
                                      );
                                      context.go('/select');
                                    },
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Franja fija que tapa la barra de estado al hacer scroll.
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 56,
                child: ColoredBox(color: AppColors.topStrip),
              ),
              BlurOverlay(
                visible: state.searching,
                title: l.searchingFlights,
                detail:
                    '${state.origin.code} → ${state.destination.code} · ${Fmt.shortDate(state.departure)}',
                loader: const SearchingTicketsLoader(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.title,
    required this.bellLabel,
  });
  final String greeting;
  final String title;
  final String bellLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: AppRadii.hero,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 40,
            width: 320,
            height: 270,
            child: DotWorldMap(
              color: AppColors.homeDots.withValues(alpha: .6),
              viewBox: DotWorldMap.asiaOceania,
            ),
          ),
          Positioned(
            left: 24,
            top: 94,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  greeting,
                  style: AppText.s(
                    13.5,
                    w: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: .75),
                  ),
                ),
                const SizedBox(height: 6),
                Txt(
                  title,
                  style: AppText.s(
                    27,
                    w: FontWeight.w800,
                    color: AppColors.white,
                    ls: -.27,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 22,
            top: 72,
            child: GlassCircleButton(
              icon: 'i-bell',
              label: bellLabel,
              dot: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.state, required this.bloc});
  final SearchState state;
  final SearchBloc bloc;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SearchCardShell(
      children: [
        SegmentedPill(
          labels: [l.tripOneWay, l.tripRound, l.tripMulti],
          selected: state.tripType.index,
          onChanged: (i) => bloc.add(TripTypeSelected(TripType.values[i])),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final picked = await showAirportPicker(
                        context,
                        title: l.chooseOrigin,
                        selected: state.origin,
                      );
                      if (picked != null) bloc.add(OriginSelected(picked));
                    },
                    child: AirportBox(
                      label: l.fromBox,
                      code: state.origin.code,
                      city: state.origin.city,
                      airport: state.origin.name,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final picked = await showAirportPicker(
                        context,
                        title: l.chooseDestination,
                        selected: state.destination,
                      );
                      if (picked != null) bloc.add(DestinationSelected(picked));
                    },
                    child: AirportBox(
                      label: l.toBox,
                      code: state.destination.code,
                      city: state.destination.city,
                      airport: state.destination.name,
                      alignEnd: true,
                    ),
                  ),
                ),
              ],
            ),
            SwapAirportsButton(
              label: l.swapAirports,
              onTap: () => bloc.add(const AirportsSwapped()),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FieldPairRow(
          left: FieldCell(
            icon: 'i-cal',
            label: l.departure,
            value: Fmt.dayMonth(state.departure),
          ),
          right: FieldCell(
            icon: 'i-ret',
            label: l.returnLabel,
            value:
                state.returnDate == null
                    ? l.addDate
                    : Fmt.dayMonth(state.returnDate!),
            placeholder: state.returnDate == null,
            trailing: FieldTrailing.plus,
          ),
        ),
        const SizedBox(height: 10),
        FieldPairRow(
          left: FieldCell(
            icon: 'i-users',
            label: l.passengersLabel,
            value: l.oneAdult,
          ),
          right: FieldCell(
            icon: 'i-grid',
            label: l.classLabel,
            value: l.economy,
          ),
        ),
        const SizedBox(height: 14),
        GradientPillButton(
          label: l.searchFlights,
          icon: 'i-search',
          fullWidth: true,
          onTap: () => bloc.add(const SearchSubmitted()),
        ),
      ],
    );
  }
}
