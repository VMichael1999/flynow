import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: false,
  fontFamily: AppText.family,
  scaffoldBackgroundColor: AppColors.background,
  canvasColor: AppColors.background,
  splashFactory: NoSplash.splashFactory,
  highlightColor: AppColors.black.withValues(alpha: 0),
  extensions: const [SkyPalette()],
);
