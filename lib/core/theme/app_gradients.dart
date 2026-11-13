import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Equivale a `linear-gradient(<angle>deg, ...)` de CSS para cualquier caja.
class CssAngle extends GradientTransform {
  const CssAngle(this.degrees);
  final double degrees;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final theta = degrees * math.pi / 180;
    final w = bounds.width;
    final h = bounds.height;
    final len = (w * math.sin(theta)).abs() + (h * math.cos(theta)).abs();
    final c = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..rotateZ(theta - math.pi / 2)
      ..scaleByDouble(len / w, 1, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
  }
}

LinearGradient cssGradient(
  double degrees,
  List<Color> colors, [
  List<double>? stops,
]) =>
    LinearGradient(colors: colors, stops: stops, transform: CssAngle(degrees));

abstract final class AppGradients {
  static const button = LinearGradient(
    colors: [Color(0xFF182163), AppColors.primaryBright],
  );
  static const buttonDisabled = LinearGradient(
    colors: [Color(0xFF8D96CF), Color(0xFFA6AFDD)],
  );
  static const appBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121A4F), Color(0xFF1E2D78)],
  );
  static final hero = cssGradient(
    160,
    const [Color(0xFF141A49), Color(0xFF1B296D), Color(0xFF2B3F9E)],
    const [0, .55, 1],
  );
  static final selectHero = cssGradient(
    170,
    const [Color(0xFF141A49), Color(0xFF1B296D), Color(0xFF2B3F9E)],
    const [0, .6, 1],
  );
  static const splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.navy900, AppColors.navy800, Color(0xFF253687)],
    stops: [0, .5, 1],
  );
  static final boardingPanel = cssGradient(
    135,
    const [Color(0xFF111853), Color(0xFF1A2672), Color(0xFF24379A)],
    const [0, .55, 1],
  );
  static const navBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xD1FFFFFF), Color(0xD1E8ECFC)],
  );
  static const ticketHeader = LinearGradient(
    colors: [AppColors.ticketBlue1, AppColors.ticketBlue2],
  );
  static const ticketHeaderRed = LinearGradient(
    colors: [AppColors.ticketRed1, AppColors.ticketRed2],
  );
  static const routeSolid = LinearGradient(
    colors: [AppColors.route, AppColors.routeEnd],
  );
  static const heroSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroSky1, AppColors.heroSky2],
  );
}

abstract final class AppShadows {
  static const ticket = [
    BoxShadow(color: Color(0x1413163A), offset: Offset(0, 8), blurRadius: 18),
  ];
  static const search = [
    BoxShadow(
      color: Color(0x8013163A),
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -26,
    ),
  ];
  static const button = [
    BoxShadow(
      color: Color(0xCC1B2A6E),
      offset: Offset(0, 10),
      blurRadius: 22,
      spreadRadius: -12,
    ),
  ];
  static const summaryBar = [
    BoxShadow(
      color: Color(0x5913163A),
      offset: Offset(0, -10),
      blurRadius: 30,
      spreadRadius: -18,
    ),
  ];
  static const segmentActive = [
    BoxShadow(
      color: Color(0x4013163A),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -4,
    ),
  ];
  static const navBarShadow = [
    BoxShadow(
      color: Color(0x7313163A),
      offset: Offset(0, 14),
      blurRadius: 34,
      spreadRadius: -14,
    ),
  ];
  static const fab = [
    BoxShadow(
      color: Color(0xCC1B2A6E),
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -10,
    ),
  ];
  static const profilePhoto = [
    BoxShadow(color: AppColors.white, spreadRadius: 4),
    BoxShadow(
      color: Color(0x6613163A),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -10,
    ),
  ];
  static const toggleKnob = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 4),
  ];
  static const pullIndicator = [
    BoxShadow(
      color: Color(0x6613163A),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -6,
    ),
  ];
  static const ticketsLoader = [
    BoxShadow(
      color: Color(0x5913163A),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -8,
    ),
  ];
}

abstract final class AppRadii {
  static const appBar = BorderRadius.vertical(bottom: Radius.circular(28));
  static const hero = BorderRadius.vertical(bottom: Radius.circular(34));
  static const selectHero = BorderRadius.vertical(bottom: Radius.circular(32));
  static const summaryBar = BorderRadius.vertical(top: Radius.circular(26));
  static const card = BorderRadius.all(Radius.circular(22));
  static const field = BorderRadius.all(Radius.circular(16));
  static const box = BorderRadius.all(Radius.circular(18));
  static const pill = BorderRadius.all(Radius.circular(27));
}

abstract final class AppDurations {
  static const screen = Duration(milliseconds: 350);
  static const flightArc = Duration(milliseconds: 3200);
  static const splashTrail = Duration(milliseconds: 1200);
  static const splashTrailDelay = Duration(milliseconds: 200);
  static const splashLogo = Duration(milliseconds: 800);
  static const splashLogoDelay = Duration(milliseconds: 500);
  static const splashTagline = Duration(milliseconds: 600);
  static const splashTaglineDelay = Duration(milliseconds: 1200);
  static const splashTotal = Duration(milliseconds: 3200);
  static const overlay = Duration(milliseconds: 300);
  static const orbit = Duration(milliseconds: 1400);
  static const sealRing = Duration(milliseconds: 900);
  static const sealPop = Duration(milliseconds: 400);
  static const swap = Duration(milliseconds: 300);
  static const searching = Duration(milliseconds: 1700);
  static const signingIn = Duration(milliseconds: 1800);
  static const paying = Duration(milliseconds: 1900);
  static const refresh = Duration(milliseconds: 900);
  static const toast = Duration(milliseconds: 2400);
  static const quick = Duration(milliseconds: 200);
  static const flyingPlane = Duration(milliseconds: 1600);
}
