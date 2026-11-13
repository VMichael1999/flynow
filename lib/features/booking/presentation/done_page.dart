import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'booking_flow_bloc.dart';

/// Reserva confirmada: sello, resumen y accesos.
class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<BookingFlowBloc>().state;
    final f = s.flight;
    final code = s.reference ?? '';
    return ScreenFrame(
      lightIcons: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 66, 22, 0),
              child: Column(
                children: [
                  const ConfirmationSeal(),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Txt(
                      l.bookingConfirmed,
                      style: AppText.s(
                        12.5,
                        w: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Txt(
                      l.headlineTrip(f.to.city),
                      style: AppText.s(27, w: FontWeight.w800, ls: -.405),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Txt(
                      l.ticketsOnWay(s.passenger.email),
                      textAlign: TextAlign.center,
                      style: AppText.s(
                        13.5,
                        w: FontWeight.w400,
                        color: AppColors.ink2,
                        h: 1.45,
                      ),
                    ),
                  ),
                  _SummaryCard(state: s, code: code),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _TwoButton(
                          icon: 'i-cal',
                          label: l.addToCalendar,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TwoButton(icon: 'i-share', label: l.share),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 44,
            child: Column(
              children: [
                GradientPillButton(
                  label: l.viewTrip,
                  icon: 'i-ticket',
                  fullWidth: true,
                  onTap: () => context.go('/trip'),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go('/home'),
                  behavior: HitTestBehavior.opaque,
                  child: Txt(
                    l.backHome,
                    style: AppText.s(
                      14.5,
                      w: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state, required this.code});
  final BookingFlowState state;
  final String code;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final f = state.flight;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.card,
        boxShadow: [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBox('i-plane', filled: true),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt(
                          '${f.from.code} → ${f.to.code}',
                          style: AppText.s(17, w: FontWeight.w800),
                        ),
                        StrutText(
                          l.oneWayFareSummary(l.economyFare(state.fare.name)),
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                          strutSize: 15,
                          lineHeight: 1.3,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Txt(
                        '1',
                        style: AppText.s(
                          11,
                          w: FontWeight.w700,
                          color: AppColors.white,
                          h: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(
                            '${f.flightNo} · ${Fmt.dayMonthLower(f.departure)}',
                            style: AppText.s(14, w: FontWeight.w700),
                          ),
                          StrutText(
                            '${f.from.code} ${Fmt.time(f.departure)} → ${f.to.code} ${Fmt.time(f.arrival)}',
                            style: AppText.s(
                              12,
                              w: FontWeight.w400,
                              color: AppColors.ink2,
                            ),
                            strutSize: 15,
                            lineHeight: 1.3,
                          ),
                        ],
                      ),
                    ),
                    Txt(
                      state.seat?.id ?? '—',
                      style: AppText.s(
                        13,
                        w: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Hairline(),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(
                        l.passengerSingle,
                        style: AppText.s(
                          12,
                          w: FontWeight.w400,
                          color: AppColors.ink3,
                        ),
                      ),
                      Txt(
                        state.passenger.fullName,
                        style: AppText.s(14.5, w: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: CustomPaint(painter: _DashedTopPainter())),
              Padding(
                // 2 px de borde punteado + 14 px de padding superior.
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt(
                          l.bookingCode,
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: GestureDetector(
                            onTap:
                                () => Clipboard.setData(
                                  ClipboardData(text: code),
                                ),
                            child: Semantics(
                              button: true,
                              label: l.copyCode,
                              child: Row(
                                children: [
                                  Txt(
                                    code,
                                    style: AppText.s(19, w: FontWeight.w800),
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
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Txt(
                          l.totalPaid,
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Txt(
                            Money.format(state.total),
                            style: AppText.s(
                              19,
                              w: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Muescas: círculos del color de fondo sobre el borde punteado.
              const Positioned(left: -8, top: -9, child: _Notch()),
              const Positioned(right: -8, top: -9, child: _Notch()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.background,
    ),
  );
}

class _DashedTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // border-top: 2px dashed #E1E4EF (trazo 6, hueco 4).
    final paint = Paint()..color = AppColors.divider;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, (size.width - x).clamp(0, 6), 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TwoButton extends StatelessWidget {
  const _TwoButton({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, color: AppColors.ink2),
          const SizedBox(height: 6),
          Txt(label, style: AppText.s(14, w: FontWeight.w700, h: 1.26)),
        ],
      ),
    );
  }
}
