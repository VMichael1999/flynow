import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'css_text.dart';

import '../theme/theme.dart';
import 'app_icon.dart';

class NavItem {
  const NavItem({required this.icon, required this.label, this.filled = false});
  final String icon;
  final String label;
  final bool filled;
}

/// Barra de navegación de vidrio (330 × 66). El ítem activo es una píldora; al
/// mantener presionado y arrastrar aparece una lente de Liquid Glass que sigue
/// el dedo y se asienta en el ítem más cercano al soltar.
class GlassNavBar extends StatefulWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with SingleTickerProviderStateMixin {
  static const _w = 330.0;
  static const _h = 66.0;
  static const _pad = 6.0;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late double _pos = widget.currentIndex.toDouble();
  double _from = 0;
  double _to = 0;
  bool _pressed = false;

  double get _itemW => (_w - 2 * _pad) / widget.items.length;

  @override
  void didUpdateWidget(GlassNavBar old) {
    super.didUpdateWidget(old);
    if (!_pressed && old.currentIndex != widget.currentIndex) {
      _glideTo(widget.currentIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _glideTo(double target) {
    _from = _pos;
    _to = target;
    _anim
      ..stop()
      ..forward(from: 0);
  }

  double _posFor(double dx) =>
      ((dx - _pad - _itemW / 2) / _itemW).clamp(0, widget.items.length - 1.0);

  void _down(PointerDownEvent e) {
    _anim.stop();
    setState(() {
      _pressed = true;
      _pos = _posFor(e.localPosition.dx);
    });
  }

  void _move(PointerMoveEvent e) =>
      setState(() => _pos = _posFor(e.localPosition.dx));

  void _up(PointerEvent e) {
    final target = _pos.round();
    setState(() => _pressed = false);
    _glideTo(target.toDouble());
    if (target != widget.currentIndex) widget.onTap(target);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    const radius = BorderRadius.all(Radius.circular(33));
    return SizedBox(
      width: _w,
      height: _h,
      child: Listener(
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: _up,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final pos =
                _pressed
                    ? _pos
                    : (_anim.isAnimating
                        ? (reduce
                            ? _to
                            : _from +
                                (_to - _from) *
                                    Curves.easeOutBack.transform(_anim.value))
                        : widget.currentIndex.toDouble());
            _pos = _pressed ? _pos : pos;
            final near = pos.round();
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: radius,
                      boxShadow: AppShadows.navBarShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: BackdropFilter(
                        filter: ui.ImageFilter.compose(
                          outer: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          inner: const ColorFilter.matrix(_saturate16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.navBar,
                            borderRadius: radius,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: .7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Píldora de degradado del ítem activo (se funde al presionar).
                Positioned(
                  left: _pad + pos * _itemW,
                  top: _pad,
                  width: _itemW,
                  height: _h - 2 * _pad,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: _pressed ? 0 : 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.button,
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(_pad),
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: _NavButton(
                            item: widget.items[i],
                            selected: i == near,
                            onDark: !_pressed,
                            onTap: () {},
                          ),
                        ),
                    ],
                  ),
                ),
                if (_pressed) _lens(pos),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Lente de vidrio líquido: crece sobre la barra y refracta lo que hay debajo.
  Widget _lens(double pos) {
    const grow = 1.34;
    final w = _itemW * grow;
    const h = 62.0;
    return Positioned(
      left: _pad + pos * _itemW + (_itemW - w) / 2,
      top: (_h - h) / 2,
      width: w,
      height: h,
      child: IgnorePointer(
        child: LiquidGlass.withOwnLayer(
          settings: LiquidGlassSettings(
            thickness: 16,
            blur: 2,
            glassColor: AppColors.white.withValues(alpha: .14),
            lightIntensity: .7,
            chromaticAberration: .02,
          ),
          shape: const LiquidRoundedSuperellipse(borderRadius: 31),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// `saturate(1.6)` como matriz de color.
const List<double> _saturate16 = [
  1.1932, -0.3576, -0.0361, 0, 0, //
  -0.1068, 0.9424, -0.0361, 0, 0,
  -0.1068, -0.3576, 1.4637, 0, 0,
  0, 0, 0, 1, 0,
];

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onDark,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;

  /// Con la píldora de degradado debajo, el ítem activo va en blanco.
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected
            ? (onDark ? AppColors.white : AppColors.primary)
            : AppColors.navInactive;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(item.icon, size: 21, color: color, filled: item.filled),
          const SizedBox(height: 3),
          Txt(
            item.label,
            style: AppText.s(12, w: FontWeight.w600, color: color, h: 1.26),
          ),
        ],
      ),
    );
  }
}

/// Botón circular de escaneo (64) junto a la barra.
class ScanFab extends StatelessWidget {
  const ScanFab({super.key, required this.label, required this.onTap});
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
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.button,
            boxShadow: AppShadows.fab,
          ),
          child: const AppIcon('i-scan', size: 24, color: AppColors.white),
        ),
      ),
    );
  }
}
