import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import '../utils/l10n_x.dart';
import 'app_icon.dart';
import 'painters.dart';
import 'space_between_row.dart';
import 'text_helpers.dart';
import 'ticket_models.dart';

const double _stub = 108;
const double _strut = 15; // div dentro de .screen: 15px, line-height 1.3
const double _lh = 1.3;

/// Pase de abordar de una sola pieza: panel azul, tira con código, talón.
class BoardingPassCard extends StatelessWidget {
  const BoardingPassCard({super.key, required this.data});
  final BoardingPassData data;

  @override
  Widget build(BuildContext context) {
    const clipper = TicketClipper(
      stubWidth: _stub,
      notchRadius: 10,
      radius: 22,
    );
    return CustomPaint(
      painter: const TicketShadowPainter(
        clipper,
        outlineAlpha: .35,
        outlineBlur: .8,
        shadowAlpha: .12,
        shadowBlur: 22,
        shadowDy: 12,
      ),
      child: ClipPath(
        clipper: clipper,
        child: ColoredBox(
          color: AppColors.white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Panel(data: data)),
                const _CodeStrip(),
                _BpStub(data: data),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeStrip extends StatelessWidget {
  const _CodeStrip();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.white,
    child: SizedBox(
      width: 24,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Center(child: VerticalBarcode()),
      ),
    ),
  );
}

TextStyle _small(
  double size,
  Color color, {
  double ls = 0.12,
  FontWeight w = FontWeight.w600,
}) => AppText.s(size, w: w, color: color, ls: size * ls, h: _lh);

class _Panel extends StatelessWidget {
  const _Panel({required this.data});
  final BoardingPassData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(gradient: AppGradients.boardingPanel),
      child: Stack(
        children: [
          const Positioned(
            left: -10,
            right: -10,
            top: 0,
            bottom: 0,
            child: DotWorldMap(color: AppColors.bpMap, slice: true),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                spaceBetweenRow(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(
                        l.labelBoardingPass,
                        softWrap: false,
                        style: AppText.s(
                          14,
                          w: FontWeight.w800,
                          color: AppColors.white,
                          ls: .98,
                          h: _lh,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const AppIcon(
                            'i-plane',
                            size: 16,
                            color: AppColors.bpPlane,
                            filled: true,
                            rotation: -30,
                          ),
                          const SizedBox(width: 6),
                          Txt(
                            data.airline,
                            style: AppText.s(
                              12,
                              w: FontWeight.w500,
                              color: AppColors.white,
                              h: _lh,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Txt(
                        l.labelBoarding,
                        style: _small(10, AppColors.bpLabel, ls: .14),
                      ),
                      Txt(
                        data.time,
                        style: AppText.s(
                          30,
                          w: FontWeight.w800,
                          color: AppColors.white,
                          ls: -.3,
                          h: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Txt(
                  l.labelPassenger,
                  style: _small(10, AppColors.bpLabel, ls: .14),
                ),
                const SizedBox(height: 3),
                Txt(
                  data.passengerName.toUpperCase(),
                  maxLines: 1,
                  style: AppText.s(
                    14,
                    w: FontWeight.w800,
                    color: AppColors.white,
                    ls: .42,
                    h: _lh,
                  ),
                ),
                const SizedBox(height: 12),
                _OriginDestination(data: data),
                const SizedBox(height: 14),
                _InfoGrid(data: data),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginDestination extends StatelessWidget {
  const _OriginDestination({required this.data});
  final BoardingPassData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget side(String label, String code, String city, CrossAxisAlignment a) =>
        Column(
          crossAxisAlignment: a,
          children: [
            StrutText(
              label,
              style: _small(10.5, AppColors.bpLabel, ls: .1),
              strutSize: _strut,
              lineHeight: _lh,
              alignment:
                  a == CrossAxisAlignment.end
                      ? Alignment.topRight
                      : Alignment.topLeft,
            ),
            Txt(
              code,
              style: AppText.s(
                26,
                w: FontWeight.w800,
                color: AppColors.white,
                h: 1.05,
              ),
            ),
            StrutText(
              city,
              style: AppText.s(
                11.5,
                w: FontWeight.w500,
                color: AppColors.bpCity,
              ),
              strutSize: _strut,
              lineHeight: _lh,
              alignment:
                  a == CrossAxisAlignment.end
                      ? Alignment.topRight
                      : Alignment.topLeft,
            ),
          ],
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        side(
          l.labelFrom,
          data.fromCode,
          data.fromCity,
          CrossAxisAlignment.start,
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 22),
            child: SizedBox(
              height: 12,
              child: CustomPaint(painter: _LinePainter()),
            ),
          ),
        ),
        side(l.labelTo, data.toCode, data.toCity, CrossAxisAlignment.end),
      ],
    );
  }
}

/// Ruta: puntos con halo, línea sólida, avión y tramo punteado.
class _LinePainter extends CustomPainter {
  const _LinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final solid =
        Paint()
          ..color = AppColors.white.withValues(alpha: .85)
          ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(4, 6.8), Offset(mid, 6.8), solid);
    final dashed =
        Paint()
          ..color = AppColors.white.withValues(alpha: .4)
          ..strokeWidth = 1.6;
    for (var x = mid; x < size.width - 4; x += 4.8 + 3.2) {
      canvas.drawLine(
        Offset(x, 6.8),
        Offset((x + 4.8).clamp(0, size.width - 4), 6.8),
        dashed,
      );
    }
    for (final cx in [3.5, size.width - 3.5]) {
      canvas.drawCircle(
        Offset(cx, 6.5),
        7.5,
        Paint()..color = AppColors.bpDot.withValues(alpha: .18),
      );
      canvas.drawCircle(Offset(cx, 6.5), 3.5, Paint()..color = AppColors.bpDot);
    }
    canvas.save();
    canvas.translate(mid, 6);
    canvas.rotate(3.14159265 / 2);
    canvas.scale(16 / 24);
    canvas.translate(-12, -12);
    canvas.drawPath(planeShape(), Paint()..color = AppColors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.data});
  final BoardingPassData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cells = [
      (l.labelGate, data.gate),
      (l.labelDate, data.dateLabel),
      (l.labelFlight, data.flightNo),
      (l.labelSeat, data.seat),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++)
              Expanded(
                child: Container(
                  decoration:
                      i == 0
                          ? null
                          : const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: AppColors.line),
                            ),
                          ),
                  child: Column(
                    children: [
                      Txt(cells[i].$1, style: _small(9.5, AppColors.ink3)),
                      StrutText(
                        cells[i].$2,
                        style: AppText.s(
                          14,
                          w: FontWeight.w800,
                          color: i == 3 ? AppColors.primary : AppColors.ink,
                        ),
                        strutSize: _strut,
                        lineHeight: _lh,
                        textAlign: TextAlign.center,
                        alignment: Alignment.topCenter,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BpStub extends StatelessWidget {
  const _BpStub({required this.data});
  final BoardingPassData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final airline = data.airline.toUpperCase();
    final split = airline.indexOf(' ');
    final airlineLines = split < 0 ? airline : airline.replaceFirst(' ', '\n');
    Widget small(String t, {double top = 7}) => Padding(
      padding: EdgeInsets.only(top: top),
      child: Txt(t, style: _small(9, AppColors.bpStubLabel)),
    );
    Widget b(String t) => Txt(
      t,
      maxLines: 1,
      softWrap: false,
      style: AppText.s(12, w: FontWeight.w800, h: _lh),
    );
    return SizedBox(
      width: _stub,
      child: CustomPaint(
        foregroundPainter: const _BpPerforation(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(1.5 + 12, 16, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 25.63,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AppIcon(
                    'i-plane',
                    size: 22,
                    color: AppColors.primary,
                    filled: true,
                    rotation: -30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Txt(
                  airlineLines,
                  style: AppText.s(
                    11,
                    w: FontWeight.w800,
                    color: AppColors.navy,
                    ls: .44,
                    h: 1.15,
                  ),
                ),
              ),
              small(l.labelPassenger),
              b(data.passengerShort),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [small(l.labelFrom), b(data.fromCode)],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [small(l.labelTo), b(data.toCode)],
                  ),
                ],
              ),
              small(l.labelBoarding),
              b(data.time),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bpSeatFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                // `inset box-shadow`: el aro no ocupa espacio de layout.
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bpSeatBorder, width: 1.8),
                ),
                child: Column(
                  children: [
                    Txt(l.labelSeat, style: _small(9, AppColors.bpSeatBorder)),
                    Txt(
                      data.seat,
                      style: AppText.s(
                        22,
                        w: FontWeight.w800,
                        color: AppColors.navy,
                        h: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BpPerforation extends CustomPainter {
  const _BpPerforation();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 1.5, size.height),
      Paint()..color = AppColors.white,
    );
    const DashedVerticalPainter(
      color: AppColors.boardingPerforation,
      width: 1.5,
    ).paint(canvas, Size(1.5, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
