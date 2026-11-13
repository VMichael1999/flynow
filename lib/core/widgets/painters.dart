import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/land_mask.dart';
import '../theme/theme.dart';
import 'app_icon.dart';

/// Celdas de tierra del mapa del prototipo, en unidades del viewBox 720×260.
final List<Offset> _landDots = () {
  final out = <Offset>[];
  for (var r = 0; r < kLandMask.length; r++) {
    final row = kLandMask[r];
    for (var c = 0; c < row.length; c++) {
      if (row.codeUnitAt(c) == 0x31) {
        out.add(Offset(2.5 + 5.0 * c, 2.5 + 5.0 * r));
      }
    }
  }
  return out;
}();

/// Mapa del mundo en puntos (proyección equirectangular, un punto cada 2.5°).
/// [viewBox] recorta la región del mapa 720×260; [slice] equivale a
/// `preserveAspectRatio="xMidYMid slice"` (si no, `meet`).
class DotWorldMap extends StatelessWidget {
  const DotWorldMap({
    super.key,
    required this.color,
    this.viewBox = const Rect.fromLTWH(0, 0, 720, 260),
    this.slice = false,
  });

  final Color color;
  final Rect viewBox;
  final bool slice;

  /// Asia y Oceanía, para la cabecera del Inicio.
  static const asiaOceania = Rect.fromLTWH(470, 0, 250, 210);

  /// Región de los tickets.
  static const ticketRegion = Rect.fromLTWH(260, 30, 260, 120);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _DotMapPainter(color, viewBox, slice),
      size: Size.infinite,
    ),
  );
}

class _DotMapPainter extends CustomPainter {
  _DotMapPainter(this.color, this.viewBox, this.slice);
  final Color color;
  final Rect viewBox;
  final bool slice;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final sx = size.width / viewBox.width;
    final sy = size.height / viewBox.height;
    final s = slice ? math.max(sx, sy) : math.min(sx, sy);
    final dx = (size.width - viewBox.width * s) / 2;
    final dy = (size.height - viewBox.height * s) / 2;
    canvas.clipRect(Offset.zero & size);
    final pts = <Offset>[];
    for (final p in _landDots) {
      if (p.dx < viewBox.left - 2 ||
          p.dx > viewBox.right + 2 ||
          p.dy < viewBox.top - 2 ||
          p.dy > viewBox.bottom + 2) {
        continue;
      }
      pts.add(
        Offset(dx + (p.dx - viewBox.left) * s, dy + (p.dy - viewBox.top) * s),
      );
    }
    canvas.drawPoints(
      ui.PointMode.points,
      pts,
      Paint()
        ..color = color
        ..strokeWidth = 2.6 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DotMapPainter o) =>
      o.color != color || o.viewBox != viewBox || o.slice != slice;
}

/// Código de barras horizontal de 72×30 (barras de 1, 2 y 3 px).
class Barcode extends StatelessWidget {
  const Barcode({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 72,
    height: 30,
    child: CustomPaint(painter: _BarcodePainter()),
  );
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.barcode;
    for (var x = 0.0; x < size.width; x += 10) {
      for (final bar in const [(0.0, 2.0), (3.0, 4.0), (6.0, 9.0)]) {
        final l = x + bar.$1;
        final r = math.min(x + bar.$2, size.width);
        if (l < size.width) {
          canvas.drawRect(Rect.fromLTRB(l, 0, r, size.height), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Código de barras vertical del pase de abordar (12 de ancho).
class VerticalBarcode extends StatelessWidget {
  const VerticalBarcode({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 12,
    child: CustomPaint(painter: _VBarcodePainter(), size: Size.fromWidth(12)),
  );
}

class _VBarcodePainter extends CustomPainter {
  const _VBarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.barcodeVertical;
    for (var y = 0.0; y < size.height; y += 13) {
      for (final bar in const [
        (0.0, 2.0),
        (3.5, 4.5),
        (6.0, 9.0),
        (10.5, 11.5),
      ]) {
        final t = y + bar.$1;
        final b = math.min(y + bar.$2, size.height);
        if (t < size.height) {
          canvas.drawRect(Rect.fromLTRB(0, t, size.width, b), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Arco de la ruta de un ticket (viewBox 100×40 estirado, como el prototipo).
class RouteArc extends StatelessWidget {
  const RouteArc({super.key, required this.duration});
  final String duration;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _RouteArcPainter()),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -6,
            child: Center(
              child: Txt(
                duration,
                style: AppText.s(11, w: FontWeight.w700, h: 1.26),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 9,
            child: Center(child: AppIconPlane()),
          ),
        ],
      ),
    );
  }
}

/// Avión de 16 rotado 90°, azul `primaryBright`.
class AppIconPlane extends StatelessWidget {
  const AppIconPlane({super.key});

  @override
  Widget build(BuildContext context) => const AppIcon(
    'i-plane',
    size: 16,
    color: AppColors.primaryBright,
    filled: true,
    rotation: 90,
  );
}

class _RouteArcPainter extends CustomPainter {
  const _RouteArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 40);
    final solid =
        Path()
          ..moveTo(3, 27)
          ..quadraticBezierTo(26, 19, 48, 17);
    canvas.drawPath(
      solid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = AppGradients.routeSolid.createShader(
          const Rect.fromLTRB(3, 17, 48, 27),
        ),
    );
    final dashed =
        Path()
          ..moveTo(52, 17)
          ..quadraticBezierTo(76, 18, 97, 27);
    final dashPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = AppColors.dashRoute;
    for (final m in dashed.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 2, m.length)), dashPaint);
        d += 5;
      }
    }
    canvas.drawCircle(
      const Offset(3, 27),
      2.2,
      Paint()..color = AppColors.route,
    );
    canvas.drawCircle(
      const Offset(97, 27),
      2.2,
      Paint()..color = AppColors.white,
    );
    canvas.drawCircle(
      const Offset(97, 27),
      2.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.routeEndHollow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ticket recortado: esquinas redondeadas y muescas semicirculares en la
/// perforación (a [stubWidth] del borde derecho, arriba y abajo).
class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({
    this.stubWidth = 104,
    this.notchRadius = 9,
    this.radius = 20,
    this.gapWidth = 0,
  });

  final double stubWidth;
  final double notchRadius;
  final double radius;
  final double gapWidth;

  @override
  Path getClip(Size size) {
    final body =
        Path()..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        );
    final cx = size.width - stubWidth;
    final top =
        Path()..addOval(
          Rect.fromCircle(center: Offset(cx, 0), radius: notchRadius),
        );
    final bottom =
        Path()..addOval(
          Rect.fromCircle(center: Offset(cx, size.height), radius: notchRadius),
        );
    return Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, body, top),
      bottom,
    );
  }

  @override
  bool shouldReclip(TicketClipper o) =>
      o.stubWidth != stubWidth ||
      o.notchRadius != notchRadius ||
      o.radius != radius;
}

/// Sombra y contorno con la silueta del ticket (`filter: drop-shadow`).
class TicketShadowPainter extends CustomPainter {
  const TicketShadowPainter(
    this.clipper, {
    this.outlineAlpha = .28,
    this.outlineBlur = .7,
    this.shadowAlpha = .08,
    this.shadowBlur = 16,
    this.shadowDy = 8,
  });
  final TicketClipper clipper;
  final double outlineAlpha;
  final double outlineBlur;
  final double shadowAlpha;
  final double shadowBlur;
  final double shadowDy;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    canvas.drawPath(
      path.shift(Offset(0, shadowDy)),
      Paint()
        ..color = AppColors.ink.withValues(alpha: shadowAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur / 2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ink.withValues(alpha: outlineAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, outlineBlur / 2),
    );
  }

  @override
  bool shouldRepaint(TicketShadowPainter o) => false;
}

/// Línea vertical punteada (borde `dashed` de CSS: trazo 3×ancho, hueco 2×ancho).
class DashedVerticalPainter extends CustomPainter {
  const DashedVerticalPainter({
    required this.color,
    required this.width,
    this.dash,
    this.gap,
  });
  final Color color;
  final double width;
  final double? dash;
  final double? gap;

  @override
  void paint(Canvas canvas, Size size) {
    final d = dash ?? width * 3;
    final g = gap ?? width * 2;
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += d + g) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, width, math.min(d, size.height - y)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
