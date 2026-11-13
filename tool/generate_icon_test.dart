import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/core/theme/land_mask.dart';
import 'package:flynow/core/theme/theme.dart';
import 'package:flynow/core/widgets/app_icon.dart';

import '../test/helpers/test_app.dart';

void main() {
  setUpAll(loadAppFonts);

  test('Render FlyNow logo and app icons', () async {
    // 1. Master showcase icon (rounded squircle) in assets/images/app_icon.png
    final showcaseBytes = await _renderIcon(1024, roundedClip: true);
    File('assets/images/app_icon.png').writeAsBytesSync(showcaseBytes);

    // 2. iOS AppIcon.appiconset (opaque full-bleed squares as required by iOS)
    const iosIcons = <String, int>{
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };
    final iosCache = <int, List<int>>{};
    for (final entry in iosIcons.entries) {
      final bytes =
          iosCache[entry.value] ??= await _renderIcon(
            entry.value,
            roundedClip: false,
          );
      File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      ).writeAsBytesSync(bytes);
    }

    // 3. Android mipmap-* ic_launcher.png (rounded squircle)
    const androidIcons = <String, int>{
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };
    for (final entry in androidIcons.entries) {
      final bytes = await _renderIcon(entry.value, roundedClip: true);
      File(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
      ).writeAsBytesSync(bytes);
    }
  });
}

Future<List<int>> _renderIcon(
  int dimension, {
  required bool roundedClip,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = dimension / 1024.0;
  canvas.scale(s, s);

  const rect = Rect.fromLTWH(0, 0, 1024, 1024);
  if (roundedClip) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(228)),
    );
  }

  // 1. Deep royal-navy gradient background (FlyNow Splash + Hero palette)
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-0.85, -1.0),
        end: Alignment(0.85, 1.0),
        colors: [
          Color(0xFF0A0D24),
          AppColors.navy900,
          AppColors.navy800,
          Color(0xFF1E2F82),
          AppColors.primaryBright,
        ],
        stops: [0.0, 0.22, 0.52, 0.80, 1.0],
      ).createShader(rect),
  );

  // Subtle ambient glow behind the ascending plane & arc
  canvas.drawCircle(
    const Offset(610, 410),
    520,
    Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.route.withValues(alpha: 0.24),
          AppColors.bpPlane.withValues(alpha: 0.12),
          AppColors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: const Offset(610, 410), radius: 520),
      ),
  );

  // Subtle top-left rim glow
  canvas.drawCircle(
    const Offset(180, 140),
    420,
    Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.homeDots.withValues(alpha: 0.14),
          AppColors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: const Offset(180, 140), radius: 420),
      ),
  );

  // 2. Signature Dot-Matrix World Map texture (from kLandMask)
  final mapScale = 1.95;
  final mapOffsetX = -210.0;
  final mapOffsetY = 170.0;
  for (var r = 0; r < kLandMask.length; r++) {
    final row = kLandMask[r];
    for (var c = 0; c < row.length; c++) {
      if (row.codeUnitAt(c) == 0x31) {
        final px = mapOffsetX + (2.5 + 5.0 * c) * mapScale;
        final py = mapOffsetY + (2.5 + 5.0 * r) * mapScale;
        if (px < 40 || px > 984 || py < 40 || py > 984) continue;
        // Soft radial vignette so dots blend into the icon edges
        final dist = (Offset(px, py) - const Offset(512, 470)).distance;
        final fade = (1.0 - (dist / 490.0)).clamp(0.0, 1.0);
        if (fade <= 0) continue;
        canvas.drawCircle(
          Offset(px, py),
          2.6 * fade + 1.0,
          Paint()
            ..color = AppColors.homeDots.withValues(alpha: 0.20 * fade),
        );
      }
    }
  }

  // 3. Secondary dashed geodesic route arc (inspired by RouteArc)
  final secondaryArc = Path()
    ..moveTo(140, 535)
    ..quadraticBezierTo(512, 345, 884, 445);
  final dashPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.5
    ..strokeCap = StrokeCap.round
    ..color = AppColors.homeDots.withValues(alpha: 0.28);
  for (final m in secondaryArc.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      canvas.drawPath(
        m.extractPath(d, math.min(d + 10, m.length)),
        dashPaint,
      );
      d += 24;
    }
  }
  // Destination hollow dot on secondary route arc (like RouteArc)
  canvas.drawCircle(
    const Offset(884, 445),
    9,
    Paint()..color = AppColors.navy800,
  );
  canvas.drawCircle(
    const Offset(884, 445),
    9,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.homeDots.withValues(alpha: 0.55),
  );

  // 4. Primary Luminous Flight Trajectory Arc (convex & ascending into the plane tail)
  final fullArc = Path()
    ..moveTo(140, 535)
    ..quadraticBezierTo(375, 285, 665, 248);
  final metric = fullArc.computeMetrics().first;
  // Trail stops right at the tail of the airplane so it flows seamlessly into the fuselage
  final trailEndOffset = metric.length * 0.90;
  final mainArc = metric.extractPath(0, trailEndOffset);
  final planeTangent = metric.getTangentForOffset(metric.length * 0.96)!;

  // Outer cyan glow along the trajectory
  canvas.drawPath(
    mainArc,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          AppColors.route.withValues(alpha: 0.0),
          AppColors.route.withValues(alpha: 0.60),
          AppColors.trailHead.withValues(alpha: 0.90),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(const Rect.fromLTRB(140, 220, 680, 535)),
  );

  // Crisp luminous core trajectory stroke
  canvas.drawPath(
    mainArc,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0x185BC0DE),
          AppColors.route,
          AppColors.trailEnd,
          AppColors.white,
        ],
        stops: [0.0, 0.28, 0.70, 1.0],
      ).createShader(const Rect.fromLTRB(140, 220, 680, 535)),
  );

  // Origin beacon dot at start of trajectory
  const startPos = Offset(140, 535);
  canvas.drawCircle(
    startPos,
    22,
    Paint()
      ..color = AppColors.route.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
  );
  canvas.drawCircle(startPos, 10, Paint()..color = AppColors.route);
  canvas.drawCircle(startPos, 4.8, Paint()..color = AppColors.white);

  // 5. Signature 4-Point Star Flare (from SplashPage) ahead of the ascending plane
  _paintStarFlare(canvas, const Offset(838, 198), 1.32);

  // 6. Hero Ascending Airplane (colinear with the arc tangent)
  final planeCenter = planeTangent.position;
  final planeAngle = planeTangent.vector.direction;
  const planeSize = 236.0;

  // Airplane deep shadow
  canvas.save();
  canvas.translate(planeCenter.dx + 8, planeCenter.dy + 22);
  canvas.rotate(planeAngle + math.pi / 2);
  canvas.translate(-planeSize / 2, -planeSize / 2);
  canvas.scale(planeSize / 24.0);
  canvas.drawPath(
    planeShape(),
    Paint()
      ..color = const Color(0x8806091A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
  );
  canvas.restore();

  // Airplane cyan halo glow
  canvas.save();
  canvas.translate(planeCenter.dx, planeCenter.dy);
  canvas.rotate(planeAngle + math.pi / 2);
  canvas.translate(-planeSize / 2, -planeSize / 2);
  canvas.scale(planeSize / 24.0);
  canvas.drawPath(
    planeShape(),
    Paint()
      ..color = AppColors.planeHalo.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
  );
  canvas.restore();

  // Airplane crisp white body with subtle ice-blue-to-white gradient
  canvas.save();
  canvas.translate(planeCenter.dx, planeCenter.dy);
  canvas.rotate(planeAngle + math.pi / 2);
  canvas.translate(-planeSize / 2, -planeSize / 2);
  canvas.scale(planeSize / 24.0);
  canvas.drawPath(
    planeShape(),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.white,
          Color(0xFFEAF6FF),
          Color(0xFFCDE8FF),
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(const Rect.fromLTWH(0, 0, 24, 24)),
  );
  canvas.restore();

  // 7. "FlyNow" Script Wordmark (KaushanScript, -6° tilt as in SplashPage)
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'FlyNow',
      style: TextStyle(
        fontFamily: 'KaushanScript',
        fontSize: 224,
        height: 1.2,
        color: AppColors.white,
        shadows: [
          Shadow(
            color: Color(0xAA060818),
            offset: Offset(0, 14),
            blurRadius: 28,
          ),
          Shadow(
            color: Color(0x445BC0DE),
            offset: Offset(0, 0),
            blurRadius: 24,
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  canvas.save();
  canvas.translate(512, 668);
  canvas.rotate(-6 * math.pi / 180);
  textPainter.paint(
    canvas,
    Offset(-textPainter.width / 2, -textPainter.height / 2),
  );
  canvas.restore();

  // Subtle inner border gloss for rounded preview
  if (roundedClip) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(3),
        const Radius.circular(225),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.28),
            AppColors.white.withValues(alpha: 0.04),
            AppColors.route.withValues(alpha: 0.18),
          ],
        ).createShader(rect),
    );
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(dimension, dimension);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void _paintStarFlare(Canvas canvas, Offset center, double scale) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.scale(scale);

  Paint blur(double a, double sigma, [Color color = AppColors.white]) =>
      Paint()
        ..color = color.withValues(alpha: a)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  canvas.drawCircle(Offset.zero, 44, blur(0.45, 24, AppColors.trailHead));
  canvas.drawCircle(Offset.zero, 22, blur(0.85, 10));

  void ray(double half, double thick, double angleRad) {
    final rect = Rect.fromLTRB(-half, -thick / 2, half, thick / 2);
    final shader = LinearGradient(
      colors: [
        AppColors.white.withValues(alpha: 0),
        AppColors.white,
        AppColors.white.withValues(alpha: 0),
      ],
    ).createShader(rect);
    canvas.save();
    canvas.rotate(angleRad);
    canvas.drawRect(
      rect.inflate(1.5),
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.restore();
  }

  ray(110, 4.0, 0);
  ray(68, 3.6, math.pi / 2);
  ray(38, 2.2, math.pi / 4);
  ray(38, 2.2, -math.pi / 4);

  canvas.drawCircle(Offset.zero, 8, blur(1, 3));
  canvas.drawCircle(Offset.zero, 4.5, Paint()..color = AppColors.white);
  canvas.restore();
}
