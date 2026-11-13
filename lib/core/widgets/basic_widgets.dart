import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import 'app_icon.dart';

/// Círculo de 44 con vidrio translúcido (barra superior). `dot` añade el
/// punto ámbar de notificaciones.
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.dot = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: .1),
            border: Border.all(color: AppColors.white.withValues(alpha: .18)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppIcon(icon, size: 19, color: AppColors.white),
              if (dot)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.amber,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra superior azul de 124 con título centrado.
class SkyAppBar extends StatelessWidget {
  const SkyAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: const BoxDecoration(
        gradient: AppGradients.appBar,
        borderRadius: AppRadii.appBar,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(child: Txt(title, style: AppText.appBar)),
          ),
          if (leading != null)
            Positioned(left: 22, bottom: 20, child: leading!),
          if (trailing != null)
            Positioned(right: 22, bottom: 20, child: trailing!),
        ],
      ),
    );
  }
}

/// Texto «Omitir» de la barra superior.
class AppBarTextAction extends StatelessWidget {
  const AppBarTextAction({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Txt(
        label,
        style: AppText.s(
          15,
          w: FontWeight.w700,
          color: AppColors.white,
          h: 1.26,
        ),
      ),
    ),
  );
}

/// Logo pequeño «FlyNow» con el arco superior, para My Flights / Status / Profile.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: CustomPaint(
        painter: _BrandArcPainter(),
        child: Txt('FlyNow', style: AppText.logo(24)),
      ),
    );
  }
}

class _BrandArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Arco sobre el texto que termina en un avioncito (a la altura de la «w»).
    final left = 14.0;
    final right = size.width - 6;
    final a = (right - left) / 2;
    const b = 16.0;
    final cx = left + a;
    const cy = 6.0;
    const end = 1.82 * math.pi;
    final stroke =
        Paint()
          ..color = AppColors.brandArc
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(cx - a, cy - b, 2 * a, 2 * b),
      math.pi,
      end - math.pi,
      false,
      stroke,
    );
    final tip = Offset(cx + a * math.cos(end), cy + b * math.sin(end));
    final tangent = math.atan2(b * math.cos(end), -a * math.sin(end));
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(tangent + math.pi / 2);
    canvas.translate(-6, -6);
    canvas.scale(12 / 24);
    canvas.drawPath(planeShape(), Paint()..color = AppColors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Botón principal con degradado (alto 54, radio 27).
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.fullWidth = false,
    this.iconFilled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final bool fullWidth;
  final bool iconFilled;

  bool get enabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        borderRadius: AppRadii.pill,
        gradient: enabled ? AppGradients.button : AppGradients.buttonDisabled,
        boxShadow: enabled ? AppShadows.button : null,
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            AppIcon(
              icon!,
              size: 19,
              color: AppColors.white,
              filled: iconFilled,
            ),
            const SizedBox(width: 8),
          ],
          Txt(label, style: AppText.button.copyWith(height: 1.26)),
        ],
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

/// Barra inferior con total, leyenda y botón (alto 116).
class PriceSummaryBar extends StatelessWidget {
  const PriceSummaryBar({
    super.key,
    required this.total,
    required this.caption,
    required this.buttonLabel,
    this.onPressed,
  });

  final String total;
  final String caption;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.summaryBar,
        boxShadow: AppShadows.summaryBar,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(total, style: AppText.s(24, w: FontWeight.w800)),
                const SizedBox(height: 2),
                Txt(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.s(12, color: AppColors.ink2),
                ),
              ],
            ),
          ),
          GradientPillButton(label: buttonLabel, onTap: onPressed),
        ],
      ),
    );
  }
}

/// Casilla de 20 con radio 6 (Recordarme, términos).
class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    super.key,
    required this.checked,
    required this.label,
    this.onChanged,
  });

  final bool checked;
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onChanged?.call(!checked),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: checked ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border:
                checked
                    ? null
                    : Border.all(color: AppColors.checkboxBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child:
              checked
                  ? const AppIcon(
                    'i-check',
                    size: 12,
                    color: AppColors.white,
                    stroke: 3.2,
                  )
                  : null,
        ),
      ),
    );
  }
}

/// Aviso con fondo `tint` y ícono de información.
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: AppIcon('i-info', size: 17, color: AppColors.ink2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Txt(text, style: AppText.s(13, w: FontWeight.w400, h: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Cuadro `tint` de 42 (o `size`) con ícono; cabecera de tarjetas.
class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    this.size = 42,
    this.radius = 12,
    this.iconSize = 19,
    this.background = AppColors.tint,
    this.color = AppColors.primary,
    this.filled = false,
    this.gradient,
  });

  final String icon;
  final double size;
  final double radius;
  final double iconSize;
  final Color background;
  final Color color;
  final bool filled;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient == null ? background : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: AppIcon(icon, size: iconSize, color: color, filled: filled),
    );
  }
}

/// Tarjeta blanca de radio 22 con contorno de 1 px (`box-shadow: 0 0 0 1px`).
class SkyCard extends StatelessWidget {
  const SkyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Línea horizontal de 1 px.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.color = AppColors.line});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 1, child: ColoredBox(color: color));
}

/// Aviso emergente sobre fondo `navy800`.
class AppToast extends StatelessWidget {
  const AppToast({super.key, required this.message, required this.visible});
  final String message;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Positioned(
      left: 22,
      right: 22,
      top: 62,
      child: IgnorePointer(
        child: AnimatedSlide(
          duration: reduce ? Duration.zero : AppDurations.quick,
          offset: visible ? Offset.zero : const Offset(0, -8 / 46),
          child: AnimatedOpacity(
            duration: reduce ? Duration.zero : AppDurations.quick,
            opacity: visible ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.navy800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const AppIcon('i-check', size: 18, color: AppColors.route),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      message,
                      style: AppText.s(
                        13.5,
                        w: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
