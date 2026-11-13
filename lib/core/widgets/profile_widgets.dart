import 'package:flutter/material.dart';
import 'css_text.dart';
import 'text_helpers.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'basic_widgets.dart';

/// Foto de 96 con anillo blanco y sombra, nombre, correo, ciudad y «Editar perfil».
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.photo,
    required this.name,
    required this.email,
    required this.homeLine,
    required this.editLabel,
  });
  final Widget photo;
  final String name;
  final String email;
  final String homeLine;
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.photoBg,
            boxShadow: AppShadows.profilePhoto,
          ),
          child: photo,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 2),
          child: Txt(name, style: AppText.s(22, w: FontWeight.w800)),
        ),
        Txt(
          email,
          style: AppText.s(13, w: FontWeight.w400, color: AppColors.ink2),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon('i-pin', size: 14, color: AppColors.ink2),
            const SizedBox(width: 5),
            Txt(
              homeLine,
              style: AppText.s(12.5, w: FontWeight.w400, color: AppColors.ink2),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: AppColors.line, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon('i-edit', size: 15),
              const SizedBox(width: 8),
              Txt(editLabel, style: AppText.s(14, w: FontWeight.w700, h: 1.26)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tres columnas con valor 22/800 y etiqueta 12.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.stats});
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration:
                    i == 0
                        ? null
                        : const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.line),
                          ),
                        ),
                child: Column(
                  children: [
                    Txt(stats[i].$1, style: AppText.s(22, w: FontWeight.w800)),
                    StrutText(
                      stats[i].$2,
                      style: AppText.s(
                        12,
                        w: FontWeight.w400,
                        color: AppColors.ink3,
                      ),
                      strutSize: 15,
                      lineHeight: 1.3,
                      alignment: Alignment.topCenter,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Etiqueta de grupo y tarjeta blanca con filas.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Txt(
            label,
            style: AppText.s(13.5, w: FontWeight.w700, color: AppColors.ink2),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: AppColors.line, spreadRadius: 1),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Hairline(color: AppColors.rowDivider),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de ajustes: ícono, texto, valor con chevron o interruptor.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.switchValue,
    this.onChanged,
  });
  final String icon;
  final String title;
  final String? value;

  /// Si no es nulo, la fila lleva un [PillSwitch].
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isSwitch = switchValue != null;
    return Semantics(
      button: true,
      toggled: isSwitch ? switchValue : null,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isSwitch ? () => onChanged?.call(!switchValue!) : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              IconBox(icon, size: 40, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Txt(title, style: AppText.s(15, w: FontWeight.w600)),
              ),
              if (isSwitch)
                PillSwitch(value: switchValue!)
              else ...[
                if (value != null) ...[
                  Txt(value!, style: AppText.s(13, color: AppColors.ink3)),
                  const SizedBox(width: 6),
                ],
                const AppIcon('i-chev', size: 16, color: AppColors.ink3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Interruptor de 48 × 28.
class PillSwitch extends StatelessWidget {
  const PillSwitch({super.key, required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final d = reduce ? Duration.zero : AppDurations.quick;
    return AnimatedContainer(
      duration: d,
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : AppColors.switchOff,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: d,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: AppShadows.toggleKnob,
          ),
        ),
      ),
    );
  }
}

/// «Cerrar sesión» en `redSoft` / `red`.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.redSoft,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: AppColors.logoutBorder, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon('i-logout', size: 20, color: AppColors.red),
              const SizedBox(width: 8),
              Txt(
                label,
                style: AppText.s(
                  15,
                  w: FontWeight.w700,
                  color: AppColors.red,
                  h: 1.26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
