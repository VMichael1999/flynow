import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'basic_widgets.dart';
import 'css_text.dart';
import 'text_helpers.dart';

/// Barra de 4 pasos (Tarifa, Pasajeros, Asientos, Pago), fija bajo la barra superior.
class BookingStepsBar extends StatelessWidget {
  const BookingStepsBar({
    super.key,
    required this.current,
    required this.names,
  });
  final int current;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.background,
            offset: Offset(0, 8),
            blurRadius: 10,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          for (var k = 0; k < names.length; k++) ...[
            if (k > 0) const SizedBox(width: 8),
            Expanded(
              child: _Step(
                name: names[k],
                done: k < current,
                now: k == current,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.name, required this.done, required this.now});
  final String name;
  final bool done;
  final bool now;

  @override
  Widget build(BuildContext context) {
    final active = done || now;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.stepPending,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              if (done) ...[
                Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const AppIcon(
                    'i-check',
                    size: 10,
                    color: AppColors.white,
                    stroke: 3.2,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Txt(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppText.s(
                    12.5,
                    w: FontWeight.w600,
                    color:
                        now
                            ? AppColors.primary
                            : (done ? AppColors.ink : AppColors.ink3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FareOption {
  const FareOption({
    required this.id,
    required this.name,
    required this.price,
    required this.tag,
    this.popular = false,
  });
  final String id;
  final String name;
  final String price;
  final String tag;
  final bool popular;
}

/// Tarjeta de tarifa seleccionable (Lite, Classic, Flex).
class FareOptionCard extends StatelessWidget {
  const FareOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.popularLabel,
    this.onTap,
  });

  final FareOption option;
  final bool selected;
  final String popularLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.name} ${option.price}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.fareSelectedBg : AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.transparent,
                  width: 1.5,
                ),
                boxShadow:
                    selected
                        ? null
                        : const [
                          BoxShadow(color: AppColors.line, spreadRadius: 1),
                        ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    option.name,
                    style: AppText.s(14.5, w: FontWeight.w700, h: 1.26),
                  ),
                  const SizedBox(height: 6),
                  Txt(
                    option.price,
                    style: AppText.s(
                      22,
                      w: FontWeight.w800,
                      color: selected ? AppColors.primary : AppColors.ink,
                      h: 1.26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Txt(
                    option.tag,
                    style: AppText.s(
                      11.5,
                      w: FontWeight.w500,
                      color: AppColors.ink2,
                      h: 1.26,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 13.5,
              top: 15.5,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : null,
                  border:
                      selected
                          ? null
                          : Border.all(
                            color: AppColors.checkboxBorder,
                            width: 1.5,
                          ),
                ),
                child:
                    selected
                        ? const AppIcon(
                          'i-check',
                          size: 12,
                          color: AppColors.white,
                          stroke: 3.2,
                        )
                        : null,
              ),
            ),
            if (option.popular)
              Positioned(
                left: 0,
                right: 0,
                top: -9.5,
                child: Center(
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Txt(
                      popularLabel,
                      maxLines: 1,
                      softWrap: false,
                      style: AppText.s(
                        10.5,
                        w: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class IncludeRow {
  const IncludeRow(this.label, this.value, {this.included = true});
  final String label;
  final String value;
  final bool included;
}

/// Tarjeta «X incluye» con filas de check o ✕.
class IncludesList extends StatelessWidget {
  const IncludesList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rows,
  });
  final String title;
  final String subtitle;
  final List<IncludeRow> rows;

  @override
  Widget build(BuildContext context) {
    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const IconBox('i-ticket'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(title, style: AppText.s(15, w: FontWeight.w700)),
                      Txt(
                        subtitle,
                        style: AppText.s(12, color: AppColors.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final r in rows) ...[
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: r.included ? AppColors.tint : AppColors.redSoft,
                    ),
                    child: AppIcon(
                      r.included ? 'i-check' : 'i-x',
                      size: 11,
                      stroke: 3,
                      color: r.included ? AppColors.primary : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Txt(r.label, style: AppText.s(14, w: FontWeight.w400)),
                  const Spacer(),
                  Txt(r.value, style: AppText.s(14, w: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta del pasajero con avatar verificado y cuadrícula 2×2.
class TravellerCard extends StatelessWidget {
  const TravellerCard({
    super.key,
    required this.initials,
    required this.caption,
    required this.name,
    required this.editLabel,
    required this.fields,
  });
  final String initials;
  final String caption;
  final String name;
  final String editLabel;
  final List<(String, String)> fields;

  @override
  Widget build(BuildContext context) {
    return SkyCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Avatar(initials: initials, verified: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(caption, style: AppText.s(12, color: AppColors.ink3)),
                      Txt(name, style: AppText.s(16, w: FontWeight.w700)),
                    ],
                  ),
                ),
                Txt(
                  editLabel,
                  style: AppText.s(
                    14,
                    w: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Hairline(),
          const SizedBox(height: 14),
          for (var i = 0; i < fields.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _KeyValue(fields[i])),
                const SizedBox(width: 14),
                Expanded(
                  child:
                      i + 1 < fields.length
                          ? _KeyValue(fields[i + 1])
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.field);
  final (String, String) field;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Txt(field.$1, style: AppText.s(12, color: AppColors.ink3)),
      const SizedBox(height: 2),
      Txt(field.$2, style: AppText.s(14.5, w: FontWeight.w600)),
    ],
  );
}

/// Avatar con iniciales; [verified] añade el check verde de 18.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.size = 46,
    this.fontSize = 14,
    this.verified = false,
    this.onDark = false,
  });
  final String initials;
  final double size;
  final double fontSize;
  final bool verified;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onDark ? AppColors.white : AppColors.tint,
            ),
            child: Txt(
              initials,
              style: AppText.s(
                fontSize,
                w: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          if (verified)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const AppIcon(
                  'i-check',
                  size: 9,
                  color: AppColors.white,
                  stroke: 3.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Campos apilados en `field`; primero con radio superior y último con inferior.
class GroupedInputCard extends StatelessWidget {
  const GroupedInputCard({super.key, required this.fields});
  final List<(String, TextEditingController)> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < fields.length; i++)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(i == 0 ? 16 : 0),
                bottom: Radius.circular(i == fields.length - 1 ? 16 : 0),
              ),
              border:
                  i == 0
                      ? null
                      : const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  fields[i].$1,
                  style: AppText.s(
                    12,
                    color: AppColors.ink3,
                    w: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 19,
                  child: EditableText(
                    controller: fields[i].$2,
                    focusNode: FocusNode(),
                    style: AppText.s(15, w: FontWeight.w500, h: 1.26),
                    cursorColor: AppColors.primary,
                    backgroundCursorColor: AppColors.line,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Píldora con el pasajero y su asiento (pantalla de asientos).
class PassengerChip extends StatelessWidget {
  const PassengerChip({
    super.key,
    required this.initials,
    required this.name,
    required this.seatLabel,
  });
  final String initials;
  final String name;
  final String seatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
      decoration: BoxDecoration(
        gradient: AppGradients.button,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(initials: initials, size: 40, fontSize: 12.5, onDark: true),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                name,
                style: AppText.s(
                  14,
                  w: FontWeight.w500,
                  color: AppColors.white,
                  h: 1.26,
                ),
              ),
              Txt(
                seatLabel,
                style: AppText.s(
                  12,
                  w: FontWeight.w500,
                  color: AppColors.white.withValues(alpha: .75),
                  h: 1.26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Casilla de extras (maleta, boleto flexible, seguro).
class ExtraOptionTile extends StatelessWidget {
  const ExtraOptionTile({
    super.key,
    required this.icon,
    required this.name,
    required this.detail,
    required this.price,
    required this.selected,
    this.onTap,
  });
  final String icon;
  final String name;
  final String detail;
  final String price;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.primary : AppColors.line,
                spreadRadius: selected ? 1.5 : 1,
              ),
            ],
          ),
          child: Row(
            children: [
              IconBox(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      name,
                      style: AppText.s(14.5, w: FontWeight.w700, h: 1.26),
                    ),
                    Txt(
                      detail,
                      style: AppText.s(12, color: AppColors.ink3, h: 1.26),
                    ),
                  ],
                ),
              ),
              Txt(price, style: AppText.s(14.5, w: FontWeight.w800, h: 1.26)),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: selected ? AppColors.primary : null,
                  border:
                      selected
                          ? null
                          : Border.all(
                            color: AppColors.checkboxBorder,
                            width: 1.5,
                          ),
                ),
                child:
                    selected
                        ? const AppIcon(
                          'i-check',
                          size: 12,
                          color: AppColors.white,
                          stroke: 3.2,
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resumen de ruta de Review & Pay con línea de ruta horizontal.
class RouteLine extends StatelessWidget {
  const RouteLine({
    super.key,
    required this.fromCode,
    required this.fromTime,
    required this.toCode,
    required this.toTime,
    required this.duration,
    this.codeSize = 17,
    this.hollowEnd = false,
    this.fromCity,
    this.toCity,
  });
  final String fromCode;
  final String fromTime;
  final String toCode;
  final String toTime;
  final String duration;
  final double codeSize;
  final bool hollowEnd;
  final String? fromCity;
  final String? toCity;

  @override
  Widget build(BuildContext context) {
    Widget side(
      String code,
      String sub,
      CrossAxisAlignment a, {
      bool city = false,
    }) => Column(
      crossAxisAlignment: a,
      children: [
        Txt(code, style: AppText.s(codeSize, w: FontWeight.w800)),
        // <small> en línea tras un bloque: la línea la fija el strut de 15 px.
        StrutText(
          sub,
          style:
              city
                  ? AppText.s(
                    12.5,
                    w: FontWeight.w600,
                    color: AppColors.cityBlue,
                  )
                  : AppText.s(12.5, color: AppColors.ink2),
          strutSize: 15,
          lineHeight: 1.3,
          alignment:
              a == CrossAxisAlignment.end
                  ? Alignment.topRight
                  : Alignment.topLeft,
        ),
      ],
    );
    return Row(
      children: [
        side(
          fromCode,
          fromCity ?? fromTime,
          CrossAxisAlignment.start,
          city: fromCity != null,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _RouteLinePainter(hollowEnd)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -12,
                    child: Center(
                      child: Txt(
                        duration,
                        style: AppText.s(11, w: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 1,
                    child: Center(
                      child: AppIcon(
                        'i-plane',
                        size: 18,
                        color: AppColors.primary,
                        filled: true,
                        rotation: 90,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        side(
          toCode,
          toCity ?? toTime,
          CrossAxisAlignment.end,
          city: toCity != null,
        ),
      ],
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  const _RouteLinePainter(this.hollowEnd);
  final bool hollowEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    canvas.drawRect(
      Rect.fromLTWH(0, 10 - 1, mid, 2),
      Paint()..color = AppColors.route,
    );
    for (var x = mid; x < size.width; x += 4 + 4) {
      canvas.drawRect(
        Rect.fromLTRB(x, 9, (x + 4).clamp(0, size.width), 11),
        Paint()..color = AppColors.checkboxBorder,
      );
    }
    canvas.drawCircle(
      const Offset(4.5, 10.5),
      4.5,
      Paint()..color = AppColors.primary,
    );
    final end = Offset(size.width - 4.5, 10.5);
    if (hollowEnd) {
      canvas.drawCircle(end, 4.5, Paint()..color = AppColors.white);
      canvas.drawCircle(
        end,
        3.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.primary,
      );
    } else {
      canvas.drawCircle(end, 4.5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
