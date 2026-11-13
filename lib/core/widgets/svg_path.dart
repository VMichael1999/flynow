import 'dart:math' as math;
import 'dart:ui';

final _num = RegExp(r'[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');
final _cmds = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)');

/// Convierte datos de trazo SVG (`d="..."`) en un [Path] de Flutter.
Path parseSvgPath(String d) {
  final path = Path();
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  var cx = 0.0, cy = 0.0;
  var prev = '';
  for (final t in _cmds.allMatches(d)) {
    final cmd = t.group(1)!;
    final a =
        _num
            .allMatches(t.group(2)!)
            .map((m) => double.parse(m.group(0)!))
            .toList();
    final rel = cmd == cmd.toLowerCase();
    final up = cmd.toUpperCase();
    if (up == 'Z') {
      path.close();
      x = sx;
      y = sy;
      prev = 'Z';
      continue;
    }
    var i = 0;
    var first = true;
    while (i < a.length) {
      final bx = rel ? x : 0.0;
      final by = rel ? y : 0.0;
      switch (up) {
        case 'M':
          final nx = a[i] + bx, ny = a[i + 1] + by;
          i += 2;
          if (first) {
            path.moveTo(nx, ny);
            sx = nx;
            sy = ny;
          } else {
            path.lineTo(nx, ny);
          }
          x = nx;
          y = ny;
        case 'L':
          x = a[i] + bx;
          y = a[i + 1] + by;
          i += 2;
          path.lineTo(x, y);
        case 'H':
          x = a[i] + bx;
          i += 1;
          path.lineTo(x, y);
        case 'V':
          y = a[i] + by;
          i += 1;
          path.lineTo(x, y);
        case 'C':
          final x2 = a[i + 2] + bx, y2 = a[i + 3] + by;
          final nx = a[i + 4] + bx, ny = a[i + 5] + by;
          path.cubicTo(a[i] + bx, a[i + 1] + by, x2, y2, nx, ny);
          i += 6;
          cx = x2;
          cy = y2;
          x = nx;
          y = ny;
        case 'S':
          final pc = prev == 'C' || prev == 'S' || prev == 'c' || prev == 's';
          final x1 = pc ? 2 * x - cx : x;
          final y1 = pc ? 2 * y - cy : y;
          final x2 = a[i] + bx, y2 = a[i + 1] + by;
          final nx = a[i + 2] + bx, ny = a[i + 3] + by;
          path.cubicTo(x1, y1, x2, y2, nx, ny);
          i += 4;
          cx = x2;
          cy = y2;
          x = nx;
          y = ny;
        case 'Q':
          final x1 = a[i] + bx, y1 = a[i + 1] + by;
          final nx = a[i + 2] + bx, ny = a[i + 3] + by;
          path.quadraticBezierTo(x1, y1, nx, ny);
          i += 4;
          cx = x1;
          cy = y1;
          x = nx;
          y = ny;
        case 'T':
          final pq = prev == 'Q' || prev == 'T' || prev == 'q' || prev == 't';
          final x1 = pq ? 2 * x - cx : x;
          final y1 = pq ? 2 * y - cy : y;
          final nx = a[i] + bx, ny = a[i + 1] + by;
          path.quadraticBezierTo(x1, y1, nx, ny);
          i += 2;
          cx = x1;
          cy = y1;
          x = nx;
          y = ny;
        case 'A':
          final rx = a[i], ry = a[i + 1], rot = a[i + 2];
          final large = a[i + 3] != 0, sweep = a[i + 4] != 0;
          final nx = a[i + 5] + bx, ny = a[i + 6] + by;
          i += 7;
          if (rx == 0 || ry == 0) {
            path.lineTo(nx, ny);
          } else {
            path.arcToPoint(
              Offset(nx, ny),
              radius: Radius.elliptical(rx, ry),
              rotation: rot * math.pi / 180,
              largeArc: large,
              clockwise: sweep,
            );
          }
          x = nx;
          y = ny;
        default:
          i = a.length;
      }
      first = false;
      prev = cmd;
    }
    prev = cmd;
  }
  return path;
}
