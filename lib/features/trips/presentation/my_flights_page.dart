import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../../search/presentation/ticket_mappers.dart';
import 'trips_bloc.dart';

/// Mis vuelos: próximo viaje, check-in y lista de boletos.
class MyFlightsPage extends StatelessWidget {
  const MyFlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<TripsBloc>();
    return BlocBuilder<TripsBloc, TripsState>(
      builder: (context, s) {
        final next = s.nextTrip;
        final snap = s.snapshot;
        return ScreenFrame(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 146, 22, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Txt(
                              l.labelNextTrip,
                              style: AppText.label(size: 12),
                            ),
                            StatusChip(
                              label: l.departsIn(Fmt.duration(next.departsIn)),
                              height: 28,
                              fontSize: 12.5,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/trip', extra: next),
                        child: BoardingPassCard(
                          data: boardingPassFromTrip(next),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: GradientPillButton(
                          label: l.doCheckIn,
                          icon: 'i-login',
                          fullWidth: true,
                          onTap:
                              () => bloc.add(CheckInRequested(next.reference)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppIcon(
                              'i-clock',
                              size: 14,
                              color: AppColors.ink2,
                            ),
                            const SizedBox(width: 6),
                            Txt(
                              l.checkInClosesOn(
                                '${Fmt.shortDate(next.checkInCloses)}, ${Fmt.time(next.checkInCloses)}',
                              ),
                              style: AppText.s(
                                12.5,
                                w: FontWeight.w400,
                                color: AppColors.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SegmentedCards(
                          items: [
                            SegmentCard(
                              l.segUpcoming,
                              l.tripsCount(snap.upcomingTotal),
                            ),
                            SegmentCard(
                              l.segPast,
                              l.tripsCount(snap.pastCount),
                            ),
                            SegmentCard(
                              l.segCancelled,
                              l.tripsCount(snap.cancelledCount),
                            ),
                          ],
                          selected: s.tab.index,
                          onChanged:
                              (i) => bloc.add(
                                TripsTabSelected(TripsTab.values[i]),
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (var i = 0; i < snap.upcoming.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        FlightTicketCard.trip(
                          data: ticketFromTrip(snap.upcoming[i], l),
                          booking: BookingStub(
                            code: snap.upcoming[i].reference,
                            note: snap.upcoming[i].note,
                            checkInOpen: snap.upcoming[i].checkInOpen,
                          ),
                          onTap:
                              () =>
                                  context.go('/trip', extra: snap.upcoming[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _TabBar(
                  title: l.myFlights,
                  trailing: GlassCircleButton(
                    icon: 'i-search',
                    label: l.search,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Barra superior de las pestañas: logo a la izquierda, título y acción.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.title, required this.trailing});
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) =>
      SkyAppBar(title: title, leading: const BrandMark(), trailing: trailing);
}
