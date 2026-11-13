import 'package:flutter/material.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import 'app_icon.dart';

/// Selector en píldora (Solo ida / Ida y vuelta / Multidestino; Número / Ruta).
class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: labels[i],
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.white : null,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow:
                          i == selected ? AppShadows.segmentActive : null,
                    ),
                    child: Txt(
                      labels[i],
                      maxLines: 1,
                      softWrap: false,
                      style: AppText.s(
                        14,
                        w: FontWeight.w600,
                        color:
                            i == selected ? AppColors.primary : AppColors.ink2,
                        h: 1.26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Caja de aeropuerto del buscador. Alineada a la derecha si es destino.
class AirportBox extends StatelessWidget {
  const AirportBox({
    super.key,
    required this.label,
    required this.code,
    required this.city,
    required this.airport,
    this.alignEnd = false,
  });
  final String label;
  final String code;
  final String city;
  final String airport;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final a = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: a,
        children: [
          Txt(
            label,
            style: AppText.s(11.5, w: FontWeight.w400, color: AppColors.ink3),
          ),
          const SizedBox(height: 6),
          Txt(code, style: AppText.s(27, w: FontWeight.w800, ls: -.27)),
          Txt(city, style: AppText.s(13, color: AppColors.ink2)),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Txt(
              airport,
              style: AppText.s(11, w: FontWeight.w400, color: AppColors.ink3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo de 40 que intercambia aeropuertos y gira 180° al tocar.
class SwapAirportsButton extends StatefulWidget {
  const SwapAirportsButton({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback onTap;

  @override
  State<SwapAirportsButton> createState() => _SwapAirportsButtonState();
}

class _SwapAirportsButtonState extends State<SwapAirportsButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          setState(() => _turns += .5);
          widget.onTap();
        },
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: AppColors.white, width: 4),
          ),
          child: AnimatedRotation(
            turns: _turns,
            duration: reduce ? Duration.zero : AppDurations.swap,
            child: const AppIcon('i-swap', size: 17, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class FieldCell {
  const FieldCell({
    required this.icon,
    required this.label,
    required this.value,
    this.placeholder = false,
    this.trailing = FieldTrailing.chevron,
  });
  final String icon;
  final String label;
  final String value;
  final bool placeholder;
  final FieldTrailing trailing;
}

enum FieldTrailing { chevron, plus }

/// Dos celdas `field` con divisor vertical (Ida / Vuelta, Pasajeros / Clase).
class FieldPairRow extends StatelessWidget {
  const FieldPairRow({super.key, required this.left, required this.right});
  final FieldCell left;
  final FieldCell right;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _Cell(left)),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
            Expanded(child: _Cell(right)),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.cell);
  final FieldCell cell;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12).copyWith(left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIcon(cell.icon, size: 13, color: AppColors.ink3),
                  const SizedBox(width: 5),
                  Txt(
                    cell.label,
                    style: AppText.s(
                      11.5,
                      w: FontWeight.w400,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Txt(
                cell.value,
                maxLines: 1,
                style:
                    cell.placeholder
                        ? AppText.s(15, color: AppColors.ink3)
                        : AppText.s(15, w: FontWeight.w700),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child:
                cell.trailing == FieldTrailing.chevron
                    ? const AppIcon('i-down', size: 16, color: AppColors.ink3)
                    : Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      child: const AppIcon(
                        'i-plus',
                        size: 12,
                        color: AppColors.ink2,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

/// Encabezado de sección: título 19/800 y acción opcional a la derecha.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });
  final String title;
  final String? action;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (trailing != null) {
      // Con un chip, el prototipo alinea por la base del ícono: el título cae
      // 6.5 px por debajo del borde superior de la fila.
      return Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.5),
              child: Txt(title, style: AppText.title),
            ),
            trailing!,
          ],
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(title, style: AppText.title),
          if (action != null)
            Txt(
              action!,
              style: AppText.s(
                13.5,
                w: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip blanco con ícono (p. ej. «Económica»).
class ChipB extends StatelessWidget {
  const ChipB({super.key, required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 15),
          const SizedBox(width: 7),
          Txt(label, style: AppText.s(13.5, w: FontWeight.w600, h: 1.26)),
        ],
      ),
    );
  }
}

/// Botón de la barra superior de dos estados usado por el formulario del Inicio.
class SearchCardShell extends StatelessWidget {
  const SearchCardShell({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.search,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
