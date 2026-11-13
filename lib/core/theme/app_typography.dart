import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto. `h` es el alto de línea (CSS `line-height`), 1.3 por defecto.
abstract final class AppText {
  static const family = 'PlusJakartaSans';
  static const logoFamily = 'KaushanScript';

  static TextStyle s(
    double size, {
    FontWeight w = FontWeight.w500,
    Color color = AppColors.ink,
    double? ls,
    double h = 1.3,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: w,
    color: color,
    letterSpacing: ls,
    height: h,
    leadingDistribution: TextLeadingDistribution.even,
    decoration: TextDecoration.none,
  );

  static TextStyle logo(
    double size, {
    Color color = AppColors.white,
    double h = 1,
  }) => TextStyle(
    fontFamily: logoFamily,
    fontSize: size,
    color: color,
    height: h,
    decoration: TextDecoration.none,
  );

  static TextStyle get headline =>
      s(27, w: FontWeight.w800, ls: -0.405, h: 1.3);
  static TextStyle get title => s(19, w: FontWeight.w800, ls: -0.19);
  static TextStyle get appBar =>
      s(17, w: FontWeight.w700, color: AppColors.white);
  static TextStyle get button =>
      s(16, w: FontWeight.w700, color: AppColors.white);
  static TextStyle label({Color color = AppColors.ink3, double size = 10.5}) =>
      s(size, w: FontWeight.w600, color: color, ls: size * 0.1);
}
