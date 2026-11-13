import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'icon_data.dart';
import 'svg_path.dart';

final Map<String, List<Path>> _cache = {};

List<Path> _pathsFor(String name) => _cache.putIfAbsent(name, () {
  final m = kIconMatrix[name];
  return [
    for (final d in kIconPaths[name]!)
      m == null
          ? parseSvgPath(d)
          : parseSvgPath(d).transform(
            Float64List.fromList([
              m[0], m[1], 0, 0, //
              m[2], m[3], 0, 0,
              0, 0, 1, 0,
              m[4], m[5], 0, 1,
            ]),
          ),
  ];
});

/// Silueta del avión (viewBox 24), para painters propios.
Path planeShape() => _pathsFor('i-plane').first;

/// Ícono de trazo del prototipo (viewBox 24, trazo 1.9). `filled` rellena el
/// contorno en lugar de trazarlo, como el avión.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color = AppColors.ink,
    this.stroke = 1.9,
    this.filled = false,
    this.rotation = 0,
  });

  final String name;
  final double size;
  final Color color;
  final double stroke;
  final bool filled;

  /// Giro en grados, como `transform: rotate()` de CSS.
  final double rotation;

  @override
  Widget build(BuildContext context) {
    Widget w = CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(name, color, stroke, filled),
    );
    if (rotation != 0) {
      w = Transform.rotate(angle: rotation * math.pi / 180, child: w);
    }
    return SizedBox.square(dimension: size, child: w);
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.name, this.color, this.stroke, this.filled);
  final String name;
  final Color color;
  final double stroke;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    final paint = Paint()..color = color;
    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    for (final p in _pathsFor(name)) {
      canvas.drawPath(p, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter o) =>
      o.name != name ||
      o.color != color ||
      o.stroke != stroke ||
      o.filled != filled;
}
