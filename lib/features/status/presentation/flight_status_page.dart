import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'flight_status_bloc.dart';

/// Estado de vuelos: consulta y tablero en vivo.
class FlightStatusPage extends StatelessWidget {
  const FlightStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<FlightStatusBloc>();
    return BlocBuilder<FlightStatusBloc, FlightStatusState>(
      builder: (context, s) {
        final board = s.board;
        final days = [
          (l.yesterday, Fmt.dayMonth(kToday.subtract(const Duration(days: 1)))),
          (l.today, Fmt.dayMonth(kToday)),
          (l.tomorrow, Fmt.dayMonth(kToday.add(const Duration(days: 1)))),
        ];
        return ScreenFrame(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 142, bottom: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SkyCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SegmentedPill(
                                labels: [l.byFlightNumber, l.byRoute],
                                selected: s.mode.index,
                                onChanged:
                                    (i) => bloc.add(
                                      StatusModeSelected(StatusMode.values[i]),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              _FlightField(
                                hint: l.flightNumberHint,
                                onChanged:
                                    (t) => bloc.add(StatusQueryChanged(t)),
                              ),
                              const SizedBox(height: 12),
                              DateTriplet(
                                items: days,
                                selected: s.dayIndex,
                                onChanged:
                                    (i) => bloc.add(StatusDaySelected(i)),
                              ),
                              const SizedBox(height: 12),
                              GradientPillButton(
                                label: l.checkStatus,
                                icon: 'i-radar',
                                fullWidth: true,
                                onTap: () => bloc.add(const StatusChecked()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.route,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.pullSpinner,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Txt(
                                  l.liveBoard,
                                  style: AppText.s(
                                    12.5,
                                    w: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Txt(
                              l.updatedNow,
                              style: AppText.s(
                                12.5,
                                w: FontWeight.w400,
                                color: AppColors.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Txt(
                              l.yourFlights,
                              style: AppText.title.copyWith(letterSpacing: 0),
                            ),
                            StrutText(
                              l.liveForTrips,
                              style: AppText.s(
                                12.5,
                                w: FontWeight.w400,
                                color: AppColors.ink3,
                              ),
                              strutSize: 15,
                              lineHeight: 1.3,
                            ),
                          ],
                        ),
                      ),
                      if (board != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            children: [
                              FlightStatusCard(
                                title:
                                    '${board.main.flightNo} · ${board.main.airline}',
                                dateLabel: board.main.dateLabel,
                                fromCode: board.main.fromCode,
                                fromCity: board.main.fromCity,
                                toCode: board.main.toCode,
                                toCity: board.main.toCity,
                                duration: board.main.duration,
                                departure: board.main.departure,
                                arrival: board.main.arrival,
                                fields: [
                                  (l.labelTerminal, board.main.terminal),
                                  (l.labelGate, board.main.gate),
                                  (l.labelBoarding, board.main.boarding),
                                ],
                                departsInLabel: l.departsInLabel,
                                departsIn: board.main.departsIn,
                                statusLabel: l.onTime,
                              ),
                              for (final u in board.upcoming) ...[
                                const SizedBox(height: 14),
                                CompactFlightRow(
                                  day: u.dayLabel,
                                  route: u.route,
                                  detail: u.detail,
                                  statusLabel: l.onTime,
                                ),
                              ],
                            ],
                          ),
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
                  title: l.flightStatus,
                  leading: const BrandMark(),
                  trailing: GlassCircleButton(
                    icon: 'i-bell',
                    label: l.notifications,
                    dot: true,
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

class _FlightField extends StatelessWidget {
  const _FlightField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.field,
        borderRadius: AppRadii.field,
      ),
      child: Row(
        children: [
          const AppIcon(
            'i-plane',
            size: 20,
            color: AppColors.ink3,
            rotation: 45,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: AppColors.primary,
              style: AppText.s(15, w: FontWeight.w500, h: 1.26),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: AppText.s(
                  15,
                  w: FontWeight.w500,
                  color: AppColors.ink3,
                  h: 1.26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
