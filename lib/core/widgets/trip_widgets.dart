import 'package:flutter/material.dart';
import 'css_text.dart';
import 'text_helpers.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'basic_widgets.dart';
import 'booking_widgets.dart';

enum ActionTone { normal, active, disabled, danger }

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.title,
    required this.detail,
    this.tone = ActionTone.normal,
    this.onTap,
  });
  final String icon;
  final String title;
  final String detail;
  final ActionTone tone;
  final VoidCallback? onTap;
}

/// Cuadrícula de 3 columnas dentro de una tarjeta (Detalle del viaje).
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.actions});
  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final rows = <List<QuickAction>>[
      for (var i = 0; i < actions.length; i += 3)
        actions.sublist(i, i + 3 > actions.length ? actions.length : i + 3),
    ];
    return SkyCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in rows[r]) Expanded(child: _ActionCell(a)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell(this.a);
  final QuickAction a;

  @override
  Widget build(BuildContext context) {
    final active = a.tone == ActionTone.active;
    final danger = a.tone == ActionTone.danger;
    final box = IconBox(
      a.icon,
      size: 48,
      radius: 14,
      iconSize: 20,
      background: danger ? AppColors.redSoft : AppColors.tint,
      color:
          active
              ? AppColors.white
              : (danger ? AppColors.red : AppColors.primary),
      gradient: active ? AppGradients.button : null,
    );
    Widget cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Column(
        children: [
          box,
          const SizedBox(height: 6),
          Txt(
            a.title,
            textAlign: TextAlign.center,
            style: AppText.s(
              13.5,
              w: FontWeight.w700,
              color: danger ? AppColors.red : AppColors.ink,
              h: 1.26,
            ),
          ),
          const SizedBox(height: 2),
          Txt(
            a.detail,
            textAlign: TextAlign.center,
            style: AppText.s(
              11.5,
              w: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.ink3,
              h: 1.26,
            ),
          ),
        ],
      ),
    );
    if (a.tone == ActionTone.disabled) {
      cell = Opacity(opacity: .45, child: cell);
    }
    return Semantics(
      button: true,
      enabled: a.tone != ActionTone.disabled,
      label: '${a.title}, ${a.detail}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: a.tone == ActionTone.disabled ? null : a.onTap,
        behavior: HitTestBehavior.opaque,
        child: cell,
      ),
    );
  }
}

/// Píldora de 34 en `#E8EBF6`: ícono o punto y texto.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.height = 34,
    this.fontSize = 13,
  });
  final String label;
  final String? icon;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.statusChip,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            AppIcon(icon!, size: 14, color: AppColors.primary)
          else
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(width: 6),
          Txt(label, style: AppText.s(fontSize, w: FontWeight.w600, h: 1.26)),
        ],
      ),
    );
  }
}

/// «A tiempo»: píldora verde de 22 con punto.
class OnTimePill extends StatelessWidget {
  const OnTimePill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PillDot(AppColors.green),
          const SizedBox(width: 5),
          Txt(
            label,
            style: AppText.s(
              11.5,
              w: FontWeight.w700,
              color: AppColors.green,
              h: 1.26,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillDot extends StatelessWidget {
  const _PillDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class DayItem {
  const DayItem(this.weekday, this.day);
  final String weekday;
  final int day;
}

/// Chips de 52 × 62 con el día de la semana y el número.
class DayChipRow extends StatelessWidget {
  const DayChipRow({
    super.key,
    required this.days,
    required this.selected,
    required this.onChanged,
  });
  final List<DayItem> days;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final on = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 52,
              height: 62,
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: on ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Txt(
                    days[i].weekday,
                    style: AppText.s(
                      12,
                      w: FontWeight.w400,
                      color:
                          on
                              ? AppColors.white.withValues(alpha: .8)
                              : AppColors.ink2,
                      h: 1.26,
                    ),
                  ),
                  Txt(
                    '${days[i].day}',
                    style: AppText.s(
                      17,
                      w: FontWeight.w700,
                      color: on ? AppColors.white : AppColors.ink,
                      h: 1.26,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ayer / Hoy / Mañana en cajas `field` de 58.
class DateTriplet extends StatelessWidget {
  const DateTriplet({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });
  final List<(String, String)> items;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: i == selected ? AppGradients.button : null,
                  color: i == selected ? null : AppColors.field,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Txt(
                      items[i].$1,
                      style: AppText.s(
                        11.5,
                        w: FontWeight.w400,
                        color:
                            i == selected
                                ? AppColors.white.withValues(alpha: .7)
                                : AppColors.ink3,
                        h: 1.26,
                      ),
                    ),
                    Txt(
                      items[i].$2,
                      style: AppText.s(
                        14,
                        w: FontWeight.w700,
                        color: i == selected ? AppColors.white : AppColors.ink,
                        h: 1.26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SegmentCard {
  const SegmentCard(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// Próximos / Pasados / Cancelados: tarjeta con segmentos de título y subtítulo.
class SegmentedCards extends StatelessWidget {
  const SegmentedCards({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });
  final List<SegmentCard> items;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: i == selected ? AppGradients.button : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Txt(
                        items[i].title,
                        style: AppText.s(
                          14.5,
                          w: FontWeight.w700,
                          color:
                              i == selected ? AppColors.white : AppColors.ink,
                          h: 1.26,
                        ),
                      ),
                      // <small> en línea dentro de un <button> (13.333 px, normal).
                      StrutText(
                        items[i].subtitle,
                        style: AppText.s(
                          11.5,
                          w: FontWeight.w400,
                          color:
                              i == selected
                                  ? AppColors.white.withValues(alpha: .75)
                                  : AppColors.ink3,
                        ),
                        strutSize: 13.333,
                        lineHeight: kNormalLineHeight,
                        alignment: Alignment.topCenter,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ticket de estado del vuelo con cabecera, ruta, horas y pie «Sale en».
class FlightStatusCard extends StatelessWidget {
  const FlightStatusCard({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.duration,
    required this.departure,
    required this.arrival,
    required this.fields,
    required this.departsInLabel,
    required this.departsIn,
    required this.statusLabel,
  });

  final String title;
  final String dateLabel;
  final String fromCode;
  final String fromCity;
  final String toCode;
  final String toCity;
  final String duration;
  final String departure;
  final String arrival;
  final List<(String, String)> fields;
  final String departsInLabel;
  final String departsIn;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 32,
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Txt(
                  title,
                  style: AppText.s(
                    12.5,
                    w: FontWeight.w700,
                    color: AppColors.white,
                    h: 1.26,
                  ),
                ),
                Txt(
                  dateLabel,
                  style: AppText.s(
                    10.5,
                    w: FontWeight.w700,
                    color: AppColors.white,
                    ls: 1.26,
                    h: 1.26,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                RouteLine(
                  fromCode: fromCode,
                  fromTime: '',
                  toCode: toCode,
                  toTime: '',
                  fromCity: fromCity,
                  toCity: toCity,
                  duration: duration,
                  codeSize: 24,
                  hollowEnd: true,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Txt(departure, style: AppText.s(13, w: FontWeight.w600)),
                    Txt(arrival, style: AppText.s(13, w: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                const Hairline(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < fields.length; i++)
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              i == 0
                                  ? CrossAxisAlignment.start
                                  : (i == 1
                                      ? CrossAxisAlignment.center
                                      : CrossAxisAlignment.end),
                          children: [
                            StrutText(
                              fields[i].$1,
                              style: AppText.label(),
                              strutSize: 15,
                              lineHeight: 1.3,
                              alignment: switch (i) {
                                0 => Alignment.topLeft,
                                1 => Alignment.topCenter,
                                _ => Alignment.topRight,
                              },
                            ),
                            const SizedBox(height: 2),
                            Txt(
                              fields[i].$2,
                              style: AppText.s(14, w: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Hairline(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppIcon(
                          'i-clock',
                          size: 13,
                          color: AppColors.ink2,
                        ),
                        const SizedBox(width: 5),
                        Txt(
                          departsInLabel,
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                    Txt(departsIn, style: AppText.s(19, w: FontWeight.w800)),
                  ],
                ),
                OnTimePill(label: statusLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila compacta de un vuelo próximo: cuadro del día, ruta, detalle y estado.
class CompactFlightRow extends StatelessWidget {
  const CompactFlightRow({
    super.key,
    required this.day,
    required this.route,
    required this.detail,
    required this.statusLabel,
  });
  final String day;
  final String route;
  final String detail;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Txt(
              day,
              style: AppText.s(11, w: FontWeight.w700, color: AppColors.ink2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(route, style: AppText.s(15, w: FontWeight.w700, h: 1.26)),
                StrutText(
                  detail,
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
          ),
          OnTimePill(label: statusLabel),
        ],
      ),
    );
  }
}
