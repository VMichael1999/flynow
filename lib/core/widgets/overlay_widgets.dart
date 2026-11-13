import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'svg_path.dart';

/// Loader: ocho puntos que crecen hacia un avión, girando una vuelta cada 1.4 s.
class PlaneOrbitLoader extends StatefulWidget {
  const PlaneOrbitLoader({super.key});

  @override
  State<PlaneOrbitLoader> createState() => _PlaneOrbitLoaderState();
}

class _PlaneOrbitLoaderState extends State<PlaneOrbitLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.orbit,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _c,
    child: const SizedBox.square(
      dimension: 120,
      child: CustomPaint(painter: _OrbitPainter()),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const c = Offset(60, 60);
    const radius = 40.0;
    final paint = Paint()..color = AppColors.primary;
    for (var k = 0; k < 8; k++) {
      final a = (k * 17) * math.pi / 180;
      canvas.drawCircle(
        Offset(c.dx + radius * math.sin(a), c.dy - radius * math.cos(a)),
        1.1 + k * 0.5,
        paint,
      );
    }
    const th = 150.0;
    final ar = th * math.pi / 180;
    canvas.save();
    canvas.translate(
      c.dx + radius * math.sin(ar),
      c.dy - radius * math.cos(ar),
    );
    canvas.rotate((th + 90) * math.pi / 180);
    canvas.translate(-14, -14);
    canvas.scale(28 / 24);
    canvas.drawPath(planeShape(), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dos tickets apilados y un avión que los cruza de izquierda a derecha.
class SearchingTicketsLoader extends StatefulWidget {
  const SearchingTicketsLoader({super.key});

  @override
  State<SearchingTicketsLoader> createState() => _SearchingTicketsLoaderState();
}

class _SearchingTicketsLoaderState extends State<SearchingTicketsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.flyingPlane,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _TicketsPainter())),
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_c.value);
              final opacity = t < .2 ? t / .2 : (1 - (t - .2) / .8);
              return Positioned(
                left: -90 + 260 * t,
                top: 20,
                child: Opacity(
                  opacity: opacity.clamp(0, 1),
                  child: const AppIcon(
                    'i-plane',
                    size: 30,
                    color: AppColors.ink,
                    filled: true,
                    rotation: 90,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TicketsPainter extends CustomPainter {
  const _TicketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(75, 55);
    canvas.rotate(-6 * math.pi / 180);
    canvas.translate(-75, -55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 22, 130, 62),
        const Radius.circular(10),
      ),
      Paint()..color = AppColors.tint.withValues(alpha: 1),
    );
    canvas.restore();
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 20, 130, 64),
      const Radius.circular(10),
    );
    canvas.drawRRect(card, Paint()..color = AppColors.white);
    canvas.drawRRect(
      card,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.divider,
    );
    final head =
        Path()
          ..moveTo(10, 30)
          ..arcToPoint(const Offset(20, 20), radius: const Radius.circular(10))
          ..lineTo(130, 20)
          ..arcToPoint(const Offset(140, 30), radius: const Radius.circular(10))
          ..lineTo(140, 38)
          ..lineTo(10, 38)
          ..close();
    canvas.drawPath(head, Paint()..color = AppColors.navy);
    final bar = Paint()..color = AppColors.statusChip;
    for (final r in const [
      Rect.fromLTWH(22, 50, 60, 6),
      Rect.fromLTWH(22, 62, 40, 6),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        bar,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(100, 50, 28, 18),
        const Radius.circular(3),
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Velo con desenfoque, loader, título y detalle.
class BlurOverlay extends StatelessWidget {
  const BlurOverlay({
    super.key,
    required this.visible,
    required this.title,
    required this.detail,
    required this.loader,
  });

  final bool visible;
  final String title;
  final String detail;
  final Widget loader;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: reduce ? Duration.zero : AppDurations.overlay,
          opacity: visible ? 1 : 0,
          child:
              visible || !reduce
                  ? ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        color: AppColors.lightBarrier.withValues(alpha: .55),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            loader,
                            const SizedBox(height: 18),
                            Txt(
                              title,
                              style: AppText.s(17, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Txt(
                              detail,
                              style: AppText.s(
                                13,
                                w: FontWeight.w500,
                                color: AppColors.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.expand(),
        ),
      ),
    );
  }
}

final Path _sealPath = parseSvgPath(
  'M42 4l8 6l10-2l4 9l9 4l-2 10l6 8l-6 8l2 10l-9 4l-4 9l-10-2l-8 6l-8-6l-10 2l-4-9l-9-4l2-10l-6-8l6-8l-2-10l9-4l4-9l10 2z',
);
final Path _checkPath = parseSvgPath('M28 42l9 9l19-19');

/// Anillo de carga y luego sello verde con check (se reinicia con [replayKey]).
class ConfirmationSeal extends StatefulWidget {
  const ConfirmationSeal({super.key});

  @override
  State<ConfirmationSeal> createState() => _ConfirmationSealState();
}

class _ConfirmationSealState extends State<ConfirmationSeal>
    with TickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: AppDurations.sealRing,
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: AppDurations.sealPop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ring.isAnimating || _ring.isCompleted || _pop.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pop.value = 1;
    } else {
      _ring.repeat();
      Future<void>.delayed(AppDurations.sealRing, () {
        if (!mounted) return;
        _ring.stop();
        _pop.forward();
      });
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 84,
      child: AnimatedBuilder(
        animation: Listenable.merge([_ring, _pop]),
        builder: (_, __) {
          if (_pop.value == 0) {
            return RotationTransition(
              turns: _ring,
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ringTrack, width: 3),
                ),
                foregroundDecoration: const BoxDecoration(),
                child: const CustomPaint(painter: _RingTopPainter()),
              ),
            );
          }
          final t = const Cubic(.2, 1.4, .4, 1).transform(_pop.value);
          return Opacity(
            opacity: (_pop.value / .75).clamp(0, 1),
            child: Transform.scale(
              scale: .6 + .4 * t,
              child: const CustomPaint(painter: _SealPainter()),
            ),
          );
        },
      ),
    );
  }
}

class _RingTopPainter extends CustomPainter {
  const _RingTopPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // border-top-color: primary, el resto del anillo gris.
    final r = Rect.fromLTWH(
      -1.5,
      -1.5,
      size.width + 3,
      size.height + 3,
    ).deflate(0);
    canvas.drawArc(
      r.deflate(0),
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SealPainter extends CustomPainter {
  const _SealPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_sealPath, Paint()..color = AppColors.green);
    canvas.drawPath(
      _checkPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
