import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import '../utils/l10n_x.dart';
import 'basic_widgets.dart';
import 'painters.dart';
import 'ticket_models.dart';
import 'text_helpers.dart';

const double _stub = 104;
const double _strut = 13.333; // <button>: 13.333px, line-height normal
const double _nl = kNormalLineHeight;

/// Boleto de vuelo de una sola pieza, con perforación y muescas.
class FlightTicketCard extends StatelessWidget {
  const FlightTicketCard._({
    super.key,
    required this.data,
    required this.stub,
    this.onTap,
  });

  /// Resultado de búsqueda: talón con «TARIFA».
  factory FlightTicketCard.result(
    BuildContext context, {
    Key? key,
    required TicketData data,
    required String price,
    VoidCallback? onTap,
  }) => FlightTicketCard._(
    key: key,
    data: data,
    stub: FareStub(label: context.l10n.labelFare, price: price),
    onTap: onTap,
  );

  /// Ruta popular: talón con «MEJOR TARIFA».
  factory FlightTicketCard.popular(
    BuildContext context, {
    Key? key,
    required TicketData data,
    required String price,
    VoidCallback? onTap,
  }) => FlightTicketCard._(
    key: key,
    data: data,
    stub: FareStub(label: context.l10n.labelBestFare, price: price),
    onTap: onTap,
  );

  /// Reserva del usuario: talón con código y, si aplica, «Check-in abierto».
  factory FlightTicketCard.trip({
    Key? key,
    required TicketData data,
    required BookingStub booking,
    VoidCallback? onTap,
  }) => FlightTicketCard._(key: key, data: data, stub: booking, onTap: onTap);

  final TicketData data;
  final TicketStub stub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const clipper = TicketClipper();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: const TicketShadowPainter(clipper),
        child: ClipPath(
          clipper: clipper,
          child: ColoredBox(
            color: AppColors.white,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _Main(data: data)),
                  _Stub(data: data, stub: stub),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Main extends StatelessWidget {
  const _Main({required this.data});
  final TicketData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient:
                data.red
                    ? AppGradients.ticketHeaderRed
                    : AppGradients.ticketHeader,
          ),
          child: Txt(
            data.airline,
            style: AppText.s(
              13,
              w: FontWeight.w700,
              color: AppColors.white,
              h: _nl,
            ),
          ),
        ),
        Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder:
                    (_, c) => Stack(
                      children: [
                        Positioned(
                          left: c.maxWidth * .1,
                          top: 6,
                          width: c.maxWidth * .8,
                          height: c.maxHeight * .8,
                          child: const DotWorldMap(
                            color: AppColors.mapLand,
                            viewBox: DotWorldMap.ticketRegion,
                            slice: true,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _City(l.labelFrom, data.fromCode, data.fromCity),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: RouteArc(duration: data.duration),
                        ),
                      ),
                      _City(l.labelTo, data.toCode, data.toCity, right: true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt(
                        data.departure,
                        style: AppText.s(13, w: FontWeight.w600, h: _nl),
                      ),
                      Txt(
                        data.arrival,
                        style: AppText.s(13, w: FontWeight.w600, h: _nl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Hairline(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Meta(
                        l.labelFlight,
                        data.flightNo,
                        CrossAxisAlignment.start,
                      ),
                      _Meta(
                        l.labelClass,
                        data.classLabel ?? l.economy,
                        CrossAxisAlignment.center,
                      ),
                      _Meta(
                        data.thirdLabel,
                        data.thirdValue,
                        CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

TextStyle _lab() => AppText.label();

class _City extends StatelessWidget {
  const _City(this.label, this.code, this.city, {this.right = false});
  final String label;
  final String code;
  final String city;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        StrutText(
          label,
          style: _lab(),
          strutSize: _strut,
          lineHeight: _nl,
          alignment: right ? Alignment.topRight : Alignment.topLeft,
        ),
        Txt(code, style: AppText.s(27, w: FontWeight.w800, ls: -.27, h: 1.1)),
        Txt(
          city,
          style: AppText.s(
            12.5,
            w: FontWeight.w600,
            color: AppColors.cityBlue,
            h: _nl,
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value, this.align);
  final String label;
  final String value;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          StrutText(
            label,
            style: _lab(),
            strutSize: _strut,
            lineHeight: _nl,
            alignment: switch (align) {
              CrossAxisAlignment.center => Alignment.topCenter,
              CrossAxisAlignment.end => Alignment.topRight,
              _ => Alignment.topLeft,
            },
          ),
          const SizedBox(height: 2),
          Txt(
            value,
            maxLines: 1,
            style: AppText.s(13, w: FontWeight.w700, h: _nl),
          ),
        ],
      ),
    );
  }
}

class _Stub extends StatelessWidget {
  const _Stub({required this.data, required this.stub});
  final TicketData data;
  final TicketStub stub;

  @override
  Widget build(BuildContext context) {
    final airColor = data.red ? AppColors.ticketRed2 : AppColors.ticketBlue2;
    return SizedBox(
      width: _stub,
      child: CustomPaint(
        foregroundPainter: const _PerforationPainter(AppColors.perforation),
        child: Padding(
          padding: const EdgeInsets.only(left: 1.5),
          child: Column(
            children: [
              Container(
                height: 36,
                width: double.infinity,
                alignment: Alignment.center,
                color: airColor,
                child: Txt(
                  data.stubDate,
                  maxLines: 1,
                  style: AppText.s(
                    10.5,
                    w: FontWeight.w700,
                    color: AppColors.white.withValues(alpha: .75),
                    ls: 1.47,
                    h: _nl,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
                  child: Column(
                    children: [
                      ..._content(context),
                      const Spacer(),
                      const Barcode(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    final l = context.l10n;
    Widget lab(String t, {double top = 0}) => Padding(
      padding: EdgeInsets.only(top: top),
      child: Txt(
        t,
        maxLines: 1,
        style: AppText.label(size: 10.5).copyWith(height: _nl),
      ),
    );
    Widget pp(String t) => Txt(
      t,
      maxLines: 1,
      style: AppText.s(11, w: FontWeight.w500, color: AppColors.ink3, h: _nl),
    );
    return switch (stub) {
      FareStub(:final label, :final price) => [
        lab(label),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Txt(
            price,
            style: AppText.s(
              25,
              w: FontWeight.w800,
              color: AppColors.primary,
              h: _nl,
            ),
          ),
        ),
        pp(l.perPerson),
      ],
      BookingStub(:final code, :final note, :final checkInOpen) => [
        if (checkInOpen)
          SizedBox(
            height: 20,
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.checkInPillBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Dot(6, AppColors.checkInPillFg),
                    const SizedBox(width: 5),
                    Txt(
                      l.checkInOpenPill,
                      maxLines: 1,
                      softWrap: false,
                      style: AppText.s(
                        9,
                        w: FontWeight.w700,
                        color: AppColors.checkInPillFg,
                        h: _nl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        lab(l.labelReservation, top: checkInOpen ? 10 : 0),
        Txt(
          code,
          maxLines: 1,
          softWrap: false,
          style: AppText.s(12, w: FontWeight.w700, h: _nl),
        ),
        pp(note),
      ],
    };
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

/// Borde izquierdo del talón: franja blanca de 1.5 con trazos `#CDD2E2`.
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 1.5, size.height),
      Paint()..color = AppColors.white,
    );
    const DashedVerticalPainter(
      color: AppColors.perforation,
      width: 1.5,
    ).paint(canvas, Size(1.5, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
