import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Arco grande de «Elige tu vuelo»: cuadrática (20,120) → (380,120), control
/// (200,−20), en un lienzo de 400 × 140. El avión recorre el arco de inicio a
/// fin una sola vez y se queda en el destino.
class FlightArcPainter extends CustomPainter {
  const FlightArcPainter(this.progress);

  /// 0 = origen, 1 = destino (ya con la curva de aceleración aplicada).
  final double progress;

  static const p0 = Offset(20, 120);
  static const c = Offset(200, -20);
  static const p2 = Offset(380, 120);

  static Offset _lerp(Offset a, Offset b, double t) => Offset.lerp(a, b, t)!;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);
    // De Casteljau: divide la cuadrática en el punto t.
    final c1 = _lerp(p0, c, t);
    final c2 = _lerp(c, p2, t);
    final pt = _lerp(c1, c2, t);
    final d = Offset(
      2 * (1 - t) * (c.dx - p0.dx) + 2 * t * (p2.dx - c.dx),
      2 * (1 - t) * (c.dy - p0.dy) + 2 * t * (p2.dy - c.dy),
    );

    // Delante del avión: tramo punteado hacia el destino.
    if (t < 1) {
      final rest =
          Path()
            ..moveTo(pt.dx, pt.dy)
            ..quadraticBezierTo(c2.dx, c2.dy, p2.dx, p2.dy);
      final dash =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = AppColors.white.withValues(alpha: .55);
      for (final m in rest.computeMetrics()) {
        var s = 0.0;
        while (s < m.length) {
          canvas.drawPath(m.extractPath(s, math.min(s + 6, m.length)), dash);
          s += 13;
        }
      }
    }

    // Detrás: estela de cometa del origen al avión.
    if (t > 0) {
      final head =
          Path()
            ..moveTo(p0.dx, p0.dy)
            ..quadraticBezierTo(c1.dx, c1.dy, pt.dx, pt.dy);
      const colors = [AppColors.trailStart, AppColors.trailHead];
      final shader = ui.Gradient.linear(p0, pt, colors);
      final glowShader = ui.Gradient.linear(p0, pt, [
        for (final c in colors) c.withValues(alpha: c.a * .8),
      ]);
      canvas.drawPath(
        head,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..shader = glowShader,
      );
      canvas.drawPath(
        head,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
    }

    // Origen: anillo translúcido; destino: punto con brillo.
    canvas.drawCircle(
      p0,
      11,
      Paint()..color = AppColors.white.withValues(alpha: .08),
    );
    canvas.drawCircle(
      p0,
      10.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.white.withValues(alpha: .3),
    );
    canvas.drawCircle(p0, 4, Paint()..color = AppColors.white);
    canvas.drawCircle(
      p2,
      8,
      Paint()
        ..color = AppColors.white.withValues(alpha: .25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(p2, 4, Paint()..color = AppColors.white);

    // Avión con halo, girado según la tangente.
    canvas.save();
    canvas.translate(pt.dx, pt.dy);
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()
        ..color = AppColors.planeHalo.withValues(alpha: .35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.rotate(math.atan2(d.dy, d.dx) + math.pi / 2);
    canvas.translate(-13, -13);
    canvas.scale(26 / 24);
    canvas.drawPath(planeShape(), Paint()..color = AppColors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FlightArcPainter o) => o.progress != progress;
}
