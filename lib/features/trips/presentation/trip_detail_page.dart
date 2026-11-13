import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../../search/presentation/ticket_mappers.dart';
import '../domain/trips_domain.dart';
import 'trips_bloc.dart';

/// Detalle del viaje: pase de abordar, acciones y barra de check-in.
class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, this.trip});

  /// Viaje a mostrar; si es nulo, la compra más reciente.
  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.watch<TripsBloc>().state;
    // Se busca la versión más reciente del viaje (p. ej. tras hacer check-in).
    final trip = state.snapshot.upcoming.firstWhere(
      (t) => t.reference == (this.trip ?? state.detailTrip).reference,
      orElse: () => this.trip ?? state.detailTrip,
    );
    return ScreenFrame(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 144, 22, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(label: l.confirmedChip, icon: 'i-bolt'),
                      StatusChip(
                        label: l.departsIn(Fmt.duration(trip.departsIn)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BoardingPassCard(data: boardingPassFromTrip(trip)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 16, 2, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Txt(
                              l.labelBookingCode,
                              style: AppText.label(size: 11),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: GestureDetector(
                                onTap:
                                    () => Clipboard.setData(
                                      ClipboardData(text: trip.reference),
                                    ),
                                child: Row(
                                  children: [
                                    Txt(
                                      trip.reference,
                                      style: AppText.s(21, w: FontWeight.w800),
                                    ),
                                    const SizedBox(width: 6),
                                    const AppIcon(
                                      'i-copy',
                                      size: 15,
                                      color: AppColors.ink3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Txt(
                              l.labelOnePassenger,
                              style: AppText.label(size: 11),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Txt(
                                l.economy,
                                style: AppText.s(16, w: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickActionGrid(
                    actions: [
                      QuickAction(
                        icon: 'i-login',
                        title: l.actCheckIn,
                        detail: l.actOpen,
                        tone: ActionTone.active,
                        onTap:
                            () => context.read<TripsBloc>().add(
                              CheckInRequested(trip.reference),
                            ),
                      ),
                      QuickAction(
                        icon: 'i-scan',
                        title: l.actBoardingPass,
                        detail: l.actAfterCheckIn,
                        tone: ActionTone.disabled,
                      ),
                      QuickAction(
                        icon: 'i-radar',
                        title: l.actFlightStatus,
                        detail: trip.flightNo,
                        onTap: () => context.go('/status'),
                      ),
                      QuickAction(
                        icon: 'i-bag',
                        title: l.actAddBaggage,
                        detail: l.fromPrice(Money.whole(16)),
                      ),
                      QuickAction(
                        icon: 'i-grid',
                        title: l.actChangeSeat,
                        detail: l.actFree,
                        onTap: () => context.go('/book/seats'),
                      ),
                      QuickAction(
                        icon: 'i-file',
                        title: l.actTicket,
                        detail: l.actPdf,
                      ),
                      QuickAction(
                        icon: 'i-cal',
                        title: l.addToCalendar,
                        detail: l.actOneFlight,
                      ),
                      QuickAction(
                        icon: 'i-share',
                        title: l.actShareTrip,
                        detail: l.actItinerary,
                      ),
                      QuickAction(
                        icon: 'i-x',
                        title: l.actCancel,
                        detail: l.actSmallFee,
                        tone: ActionTone.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SkyAppBar(
              title: l.tripDetail,
              leading: BackButtonGlass(() => context.go('/flights')),
              trailing: GlassCircleButton(icon: 'i-share', label: l.share),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CheckInBar(
              title: l.checkInOpenTitle,
              caption: l.closesOn(
                '${Fmt.shortDate(trip.checkInCloses)}, ${Fmt.time(trip.checkInCloses)}',
              ),
              button: l.actCheckIn,
              onTap:
                  () => context.read<TripsBloc>().add(
                    CheckInRequested(trip.reference),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInBar extends StatelessWidget {
  const _CheckInBar({
    required this.title,
    required this.caption,
    required this.button,
    required this.onTap,
  });
  final String title;
  final String caption;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.summaryBar,
        boxShadow: AppShadows.summaryBar,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(title, style: AppText.s(17, w: FontWeight.w800)),
                StrutText(
                  caption,
                  style: AppText.s(
                    12.5,
                    w: FontWeight.w400,
                    color: AppColors.ink2,
                  ),
                  strutSize: 15,
                  lineHeight: 1.3,
                ),
              ],
            ),
          ),
          GradientPillButton(label: button, icon: 'i-login', onTap: onTap),
        ],
      ),
    );
  }
}
