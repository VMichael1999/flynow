import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../utils/l10n_x.dart';
import 'basic_widgets.dart';
import 'booking_widgets.dart';

/// Fondo de pantalla con el color de la barra de estado ajustado:
/// [lightIcons] = íconos claros sobre cabecera oscura.
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.lightIcons = true,
    this.background = AppColors.background,
  });
  final Widget child;
  final bool lightIcons;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness:
            lightIcons ? Brightness.light : Brightness.dark,
        statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      ),
      child: ColoredBox(color: background, child: child),
    );
  }
}

/// Pantalla de la compra: barra superior, pasos fijos, contenido con scroll y
/// barra de resumen inferior.
class BookingScaffold extends StatelessWidget {
  const BookingScaffold({
    super.key,
    required this.title,
    required this.step,
    required this.stepNames,
    required this.onBack,
    required this.body,
    required this.summary,
    this.trailing,
  });

  final String title;
  final int step;
  final List<String> stepNames;
  final VoidCallback onBack;
  final Widget body;
  final Widget summary;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            top: 124,
            child: BookingStepsBar(current: step, names: stepNames),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SkyAppBar(
              title: title,
              leading: BackButtonGlass(onBack),
              trailing: trailing,
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: summary),
        ],
      ),
    );
  }
}

/// Botón de volver de la barra superior.
class BackButtonGlass extends StatelessWidget {
  const BackButtonGlass(this.onTap, {super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      GlassCircleButton(icon: 'i-back', label: context.l10n.back, onTap: onTap);
}
