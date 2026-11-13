import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import 'app_icon.dart';

enum SeatKind { free, taken, extra, selected }

/// Estrategia visual de cada asiento: colores, borde y si se puede tocar.
class SeatStyle {
  const SeatStyle({
    required this.fill,
    required this.band,
    required this.text,
    this.ring,
    this.tappable = true,
  });

  final Color fill;
  final Color band;
  final Color text;
  final Color? ring;
  final bool tappable;

  factory SeatStyle.of(SeatKind kind) => switch (kind) {
    SeatKind.free => const SeatStyle(
      fill: AppColors.white,
      ring: AppColors.seatFreeBorder,
      band: AppColors.seatFreeEdge,
      text: AppColors.seatFreeText,
    ),
    SeatKind.taken => const SeatStyle(
      fill: AppColors.seatTaken,
      band: AppColors.seatTakenEdge,
      text: AppColors.transparent,
      tappable: false,
    ),
    SeatKind.extra => const SeatStyle(
      fill: AppColors.seatExtra,
      ring: AppColors.seatExtraBorder,
      band: AppColors.seatExtraEdge,
      text: AppColors.seatExtraText,
    ),
    SeatKind.selected => const SeatStyle(
      fill: AppColors.primary,
      band: AppColors.seatSelectedEdge,
      text: AppColors.white,
    ),
  };
}

class _SeatPainter extends CustomPainter {
  const _SeatPainter(this.style);
  final SeatStyle style;
  static const radii = [9.0, 9.0, 6.0, 6.0];

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: Radius.circular(radii[0]),
      topRight: Radius.circular(radii[1]),
      bottomRight: Radius.circular(radii[2]),
      bottomLeft: Radius.circular(radii[3]),
    );
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRRect(rr, Paint()..color = style.fill);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 4, size.width, 4),
      Paint()..color = style.band,
    );
    if (style.ring != null) {
      canvas.drawRRect(
        rr.deflate(.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = style.ring!,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeatPainter o) => o.style != style;
}

/// Asiento de la cabina. El seleccionado muestra las iniciales.
class SeatButton extends StatelessWidget {
  const SeatButton({
    super.key,
    required this.kind,
    required this.label,
    required this.semanticsLabel,
    this.onTap,
  });

  final SeatKind kind;
  final String label;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = SeatStyle.of(kind);
    return Semantics(
      button: style.tappable,
      enabled: style.tappable,
      selected: kind == SeatKind.selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: style.tappable ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 42,
          child: CustomPaint(
            painter: _SeatPainter(style),
            child: Center(
              child: Txt(
                label,
                style: AppText.s(
                  12.5,
                  w: FontWeight.w700,
                  color: style.text,
                  h: 1.26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Leyenda: Libre, Elegido, Ocupado, Más espacio.
class SeatLegend extends StatelessWidget {
  const SeatLegend({
    super.key,
    required this.free,
    required this.chosen,
    required this.taken,
    required this.extra,
  });
  final String free;
  final String chosen;
  final String taken;
  final String extra;

  @override
  Widget build(BuildContext context) {
    Widget item(SeatKind k, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 16,
          child: CustomPaint(painter: _LegendSwatch(SeatStyle.of(k))),
        ),
        const SizedBox(width: 6),
        Txt(t, style: AppText.s(12, w: FontWeight.w400, color: AppColors.ink2)),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        item(SeatKind.free, free),
        item(SeatKind.selected, chosen),
        item(SeatKind.taken, taken),
        item(SeatKind.extra, extra),
      ],
    );
  }
}

class _LegendSwatch extends CustomPainter {
  const _LegendSwatch(this.style);
  final SeatStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    canvas.drawRRect(rr, Paint()..color = style.fill);
    if (style.ring != null) {
      canvas.drawRRect(
        rr.deflate(.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = style.ring!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un asiento de la cabina para pintarlo en [SeatMap].
class SeatCell {
  const SeatCell({
    required this.id,
    required this.column,
    required this.kind,
    required this.semanticsLabel,
  });
  final String id;
  final String column;
  final SeatKind kind;
  final String semanticsLabel;
}

/// Fuselaje de 250 con nariz punteada, baños, cocina y filas de asientos.
class SeatMap extends StatelessWidget {
  const SeatMap({
    super.key,
    required this.rows,
    required this.exitRows,
    required this.selectedInitials,
    required this.wcLabel,
    required this.exitLabel,
    required this.onSeatTap,
    this.footer,
  });

  /// `rows[i]` contiene los 4 asientos A, B, C, D de la fila `i + 1`.
  final List<List<SeatCell>> rows;
  final Set<int> exitRows;
  final String selectedInitials;
  final String wcLabel;
  final String exitLabel;
  final ValueChanged<String> onSeatTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        padding: const EdgeInsets.fromLTRB(18, 70, 18, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(125)),
          boxShadow: [BoxShadow(color: AppColors.line, spreadRadius: 1)],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                _Facilities(wcLabel: wcLabel),
                const SizedBox(height: 10),
                _Columns(),
                const SizedBox(height: 6),
                for (var i = 0; i < rows.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SeatRow(
                      number: i + 1,
                      cells: rows[i],
                      exit: exitRows.contains(i + 1),
                      exitLabel: exitLabel,
                      initials: selectedInitials,
                      onTap: onSeatTap,
                    ),
                  ),
                if (footer != null) footer!,
              ],
            ),
            // La nariz va 70 px por encima del contenido: top 26 respecto al fuselaje.
            const Positioned(
              left: 125 - 18 - 60,
              top: 26 - 70,
              width: 120,
              height: 40,
              child: CustomPaint(painter: _NosePainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Facilities extends StatelessWidget {
  const _Facilities({required this.wcLabel});
  final String wcLabel;

  @override
  Widget build(BuildContext context) {
    Widget box(Widget? child) => Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration:
            child == null
                ? null
                : BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.field,
                ),
        foregroundDecoration: child == null ? null : _InsetBottom.instance,
        child: child,
      ),
    );
    return Row(
      children: [
        box(
          Txt(
            wcLabel,
            style: AppText.s(12, w: FontWeight.w600, color: AppColors.ink3),
          ),
        ),
        const SizedBox(width: 6),
        const SizedBox(width: 26),
        const SizedBox(width: 6),
        box(const AppIcon('i-coffee', size: 16, color: AppColors.ink3)),
      ],
    );
  }
}

/// `box-shadow: inset 0 -1.5px 0 #E1E4EF`.
class _InsetBottom extends Decoration {
  const _InsetBottom();
  static const instance = _InsetBottom();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _InsetBottomPainter();
}

class _InsetBottomPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size!;
    final rr = RRect.fromRectAndRadius(
      offset & size,
      const Radius.circular(10),
    );
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy + size.height - 1.5, size.width, 1.5),
      Paint()..color = AppColors.divider,
    );
    canvas.restore();
  }
}

class _Columns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget c(String t) => Expanded(
      child: Center(
        child: Txt(
          t,
          style: AppText.s(12, w: FontWeight.w600, color: AppColors.ink3),
        ),
      ),
    );
    return Row(
      children: [
        c('A'),
        const SizedBox(width: 6),
        c('B'),
        const SizedBox(width: 6),
        const SizedBox(width: 26),
        const SizedBox(width: 6),
        c('C'),
        const SizedBox(width: 6),
        c('D'),
      ],
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.number,
    required this.cells,
    required this.exit,
    required this.exitLabel,
    required this.initials,
    required this.onTap,
  });
  final int number;
  final List<SeatCell> cells;
  final bool exit;
  final String exitLabel;
  final String initials;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    Widget seat(SeatCell c) => Expanded(
      child: SeatButton(
        kind: c.kind,
        label:
            c.kind == SeatKind.selected
                ? initials
                : (c.kind == SeatKind.taken ? '' : c.column),
        semanticsLabel: c.semanticsLabel,
        onTap: () => onTap(c.id),
      ),
    );
    return SizedBox(
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              seat(cells[0]),
              const SizedBox(width: 6),
              seat(cells[1]),
              const SizedBox(width: 6),
              SizedBox(
                width: 26,
                child: Center(
                  child: Txt(
                    '$number',
                    style: AppText.s(
                      11.5,
                      w: FontWeight.w600,
                      color: AppColors.ink3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              seat(cells[2]),
              const SizedBox(width: 6),
              seat(cells[3]),
            ],
          ),
          if (exit) ...[
            Positioned(
              left: -46,
              child: _ExitMark(label: exitLabel, reversed: false),
            ),
            Positioned(
              right: -46,
              child: _ExitMark(label: exitLabel, reversed: true),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExitMark extends StatelessWidget {
  const _ExitMark({required this.label, required this.reversed});
  final String label;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: 4,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    final text = Txt(
      label,
      style: AppText.s(
        9.5,
        w: FontWeight.w800,
        color: AppColors.primary,
        ls: .57,
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          reversed
              ? [bar, const SizedBox(width: 3), text]
              : [text, const SizedBox(width: 3), bar],
    );
  }
}

/// Nariz del avión: borde superior de 6 px, punteado, que se afina hacia los lados.
class _NosePainter extends CustomPainter {
  const _NosePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const r = 40.0; // radios escalados: 60 → 40 porque el alto es 40
    const t = 6.0;
    final flat = size.width - 2 * r; // 40
    final arc = r * math.pi / 2;
    final total = 2 * arc + flat;
    const n = 10;
    const dash = 12.0;
    final gap = (total - dash * n) / (n - 1);

    // Punto exterior y grosor en cada tramo, medido desde el origen del borde.
    (Offset, Offset) at(double u) {
      if (u < arc) {
        final th = u / r; // 0 en el costado, π/2 arriba
        final outer = Offset(r - r * math.cos(th), r - r * math.sin(th));
        final k = math.sin(th); // grosor: 0 en el costado, 6 arriba
        final inward = Offset(math.cos(th), math.sin(th));
        return (outer, outer + inward * (t * k));
      }
      if (u < arc + flat) {
        final x = r + (u - arc);
        return (Offset(x, 0), Offset(x, t));
      }
      final th = (u - arc - flat) / r; // 0 arriba, π/2 costado
      final outer = Offset(
        size.width - r + r * math.sin(th),
        r - r * math.cos(th),
      );
      final k = math.cos(th);
      final inward = Offset(-math.sin(th), math.cos(th));
      return (outer, outer + inward * (t * k));
    }

    final paint = Paint()..color = AppColors.primary;
    for (var i = 0; i < n; i++) {
      final u0 = i * (dash + gap);
      final u1 = u0 + dash;
      final outer = <Offset>[];
      final inner = <Offset>[];
      const steps = 12;
      for (var s = 0; s <= steps; s++) {
        final p = at(u0 + (u1 - u0) * s / steps);
        outer.add(p.$1);
        inner.add(p.$2);
      }
      final path = Path()..moveTo(outer.first.dx, outer.first.dy);
      for (final o in outer.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      for (final o in inner.reversed) {
        path.lineTo(o.dx, o.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
