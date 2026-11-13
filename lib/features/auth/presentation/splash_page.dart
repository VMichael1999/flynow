import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';

/// Animación de inicio: el avión dibuja el arco y aparece el logo.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.splashTotal,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      Future<void>.delayed(const Duration(milliseconds: 1500), _next);
    } else {
      _c.forward().whenComplete(_next);
    }
  }

  void _next() {
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _phase(Duration delay, Duration length) {
    final total = AppDurations.splashTotal.inMilliseconds;
    final start = delay.inMilliseconds / total;
    final end = (delay + length).inMilliseconds / total;
    return ((_c.value - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ScreenFrame(
      background: AppColors.navy900,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final arc = _phase(
              AppDurations.splashTrailDelay,
              AppDurations.splashTrail,
            );
            // Transformación avión → estrella: empieza hacia el 60 % del arco y
            // sigue ~1 s después de llegar, para que sea gradual.
            final glow = ((_c.value - .2875) / .34).clamp(0.0, 1.0);
            final logo = Curves.ease.transform(
              _phase(AppDurations.splashLogoDelay, AppDurations.splashLogo),
            );
            final tag = Curves.ease.transform(
              _phase(
                AppDurations.splashTaglineDelay,
                AppDurations.splashTagline,
              ),
            );
            return Stack(
              children: [
                Positioned(
                  left: 110,
                  top: 374,
                  width: 250,
                  height: 70,
                  child: CustomPaint(painter: _SplashArcPainter(arc, glow)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 400,
                  child: Center(
                    child: Opacity(
                      opacity: logo,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - logo)),
                        child: Transform.rotate(
                          angle: -6 * math.pi / 180,
                          child: Txt('FlyNow', style: AppText.logo(68, h: 1.3)),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 520,
                  child: Opacity(
                    opacity: tag,
                    child: Txt(
                      l.splashTagline,
                      textAlign: TextAlign.center,
                      style: AppText.s(
                        15,
                        w: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: .6),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashArcPainter extends CustomPainter {
  const _SplashArcPainter(this.progress, this.glow);
  final double progress;
  final double glow;

  static Path get _path =>
      Path()
        ..moveTo(10, 60)
        ..quadraticBezierTo(130, -10, 240, 36);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path;
    final metric = path.computeMetrics().first;
    final e = Curves.ease.transform(progress);
    final reveal = metric.length * e; // la estela y el avión avanzan juntos
    if (reveal > 0) {
      canvas.drawPath(
        metric.extractPath(0, reveal),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            colors: [AppColors.trailStart, AppColors.trailEnd],
          ).createShader(const Rect.fromLTRB(10, 0, 240, 70)),
      );
    }
    final opacity = Curves.ease.transform((progress / .15).clamp(0.0, 1.0));
    if (progress <= 0) return;
    final tangent = metric.getTangentForOffset(metric.length * e);
    if (tangent == null) return;
    final pos = tangent.position;
    // El avión se transforma en estrella al llegar: se desvanece mientras
    // el destello crece.
    final star = Curves.easeInOutCubic.transform(glow);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.save();
    canvas.rotate(tangent.vector.direction);
    canvas.rotate(math.pi / 2);
    canvas.translate(-9, -9);
    canvas.scale(18 / 24);
    canvas.drawPath(
      planeShape(),
      Paint()..color = AppColors.white.withValues(alpha: opacity * (1 - star)),
    );
    canvas.restore();
    if (star > 0) _paintStar(canvas, star);
    canvas.restore();
  }

  /// Destello de cuatro puntas: núcleo blanco, halo y rayos horizontal/vertical.
  void _paintStar(Canvas canvas, double k) {
    Paint blur(double a, double sigma) =>
        Paint()
          ..color = AppColors.white.withValues(alpha: a * k)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    canvas.drawCircle(Offset.zero, 26, blur(.55, 16));
    canvas.drawCircle(Offset.zero, 12, blur(.8, 7));
    void ray(double half, double thick, bool vertical) {
      final rect = Rect.fromLTRB(-half, -thick / 2, half, thick / 2);
      final shader = LinearGradient(
        colors: [
          AppColors.white.withValues(alpha: 0),
          AppColors.white.withValues(alpha: k),
          AppColors.white.withValues(alpha: 0),
        ],
      ).createShader(rect);
      canvas.save();
      if (vertical) canvas.rotate(math.pi / 2);
      canvas.drawRect(
        rect.inflate(1),
        Paint()
          ..shader = shader
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
      canvas.restore();
    }

    ray(78 * k, 2.2, false);
    ray(36 * k, 2, true);
    canvas.drawCircle(Offset.zero, 4.5, blur(1, 2));
    canvas.drawCircle(
      Offset.zero,
      2.4,
      Paint()..color = AppColors.white.withValues(alpha: k),
    );
  }

  @override
  bool shouldRepaint(_SplashArcPainter o) =>
      o.progress != progress || o.glow != glow;
}
