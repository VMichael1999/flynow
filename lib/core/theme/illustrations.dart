import 'package:flutter/material.dart';

import '../widgets/svg_path.dart';

/// Ilustración provisional del login (viajera en la parada con montañas).
/// Equivale al SVG del prototipo; se sustituye por `assets/images/login_hero.png`
/// cuando exista el arte final (mismo tamaño 440 × 330 y misma posición).
class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: double.infinity,
    height: 330,
    child: CustomPaint(painter: _HeroPainter()),
  );
}

Paint _fill(int argb) => Paint()..color = Color(argb);

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 440×330, xMidYMid slice.
    final s =
        size.width / 440 > size.height / 330
            ? size.width / 440
            : size.height / 330;
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - 440 * s) / 2, (size.height - 330 * s) / 2);
    canvas.scale(s);
    const rect = Rect.fromLTWH(0, 0, 440, 330);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCEBFA), Color(0xFFEEF4FC)],
        ).createShader(rect),
    );
    final cloud = Paint()..color = const Color(0xE6FFFFFF);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(40, 70), width: 80, height: 20),
      cloud,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(400, 60), width: 68, height: 18),
      cloud,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(300, 120), width: 48, height: 14),
      cloud,
    );
    canvas.drawPath(
      parseSvgPath('M0 250l70-110l60 70l60-90l90 120l60-60l100 90v70h-440z'),
      _fill(0xFF9AA6E4),
    );
    canvas.drawPath(
      parseSvgPath('M0 270l90-90l70 70l70-50l100 80l110-60v110h-440z'),
      _fill(0xFF7E89D4),
    );
    canvas.drawPath(
      parseSvgPath('M60 140l20 20l-30 10z M190 120l20 25l-28 4z'),
      _fill(0xFFE9ECFA),
    );
    canvas.drawPath(
      parseSvgPath('M0 300q60-40 120 0t140 0t180 0v30h-440z'),
      _fill(0xFF6A75C4),
    );
    final white = _fill(0xFFFFFFFF);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(40, 300), width: 100, height: 44),
      white,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(420, 290), width: 120, height: 52),
      white,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(380, 300), width: 80, height: 40),
      white,
    );
    // Poste y letrero de la parada.
    canvas.drawRect(const Rect.fromLTWH(356, 90, 5, 230), _fill(0xFF9A9CA8));
    final sign = RRect.fromRectAndRadius(
      const Rect.fromLTWH(330, 58, 56, 56),
      const Radius.circular(10),
    );
    canvas.drawRRect(sign, _fill(0xFFF2B53A));
    canvas.drawRRect(
      sign,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFC78F1E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(342, 70, 32, 26),
        const Radius.circular(6),
      ),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(346, 74, 24, 10),
        const Radius.circular(2),
      ),
      _fill(0xFF5A5F7A),
    );
    canvas.drawCircle(const Offset(349, 100), 3, _fill(0xFF5A5F7A));
    canvas.drawCircle(const Offset(367, 100), 3, _fill(0xFF5A5F7A));
    canvas.drawPath(
      parseSvgPath('M410 330v-130q-14-30 0-60q14 30 0 60'),
      Paint()..color = const Color(0xCC7E89D4),
    );
    // Viajera.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(196, 270, 26, 60),
        const Radius.circular(6),
      ),
      _fill(0xFF5A6280),
    );
    canvas.drawPath(
      parseSvgPath('M190 196q18-16 40 0l6 80h-52z'),
      _fill(0xFF2E8C8C),
    );
    canvas.drawPath(
      parseSvgPath('M230 202l60-12l2 8l-58 16z'),
      _fill(0xFFF1C29C),
    );
    final bag = RRect.fromRectAndRadius(
      const Rect.fromLTWH(168, 196, 34, 50),
      const Radius.circular(10),
    );
    canvas.drawRRect(bag, _fill(0xFFE9A62E));
    canvas.drawRRect(
      bag,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFB27918),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(174, 210, 22, 14),
        const Radius.circular(3),
      ),
      _fill(0xFFC9891F),
    );
    canvas.drawCircle(const Offset(214, 178), 16, _fill(0xFFF1C29C));
    canvas.drawPath(
      parseSvgPath('M198 176q2-24 22-20q14 4 10 22q-8-12-24-6q-2 14-8 4z'),
      _fill(0xFF263068),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(178, 280, 34, 10),
        const Radius.circular(3),
      ),
      _fill(0xFF2D2F44),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Foto de perfil provisional (96 × 96); sustituible por `profile_photo.png`.
class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 96,
    child: CustomPaint(painter: _FacePainter()),
  );
}

class _FacePainter extends CustomPainter {
  const _FacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _fill(0xFFDCE1F2));
    canvas.drawPath(
      parseSvgPath('M14 96q2-26 34-30q32 4 34 30z'),
      _fill(0xFF2B2F44),
    );
    canvas.drawPath(parseSvgPath('M40 62h16v10l-8 5l-8-5z'), _fill(0xFFD9A47E));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(48, 44), width: 34, height: 40),
      _fill(0xFFE9B993),
    );
    canvas.drawPath(
      parseSvgPath(
        'M29 42q-4-22 14-26q20-6 26 12q4 10-2 16q0-14-10-16q-14-2-20 4q-6 2-8 10z',
      ),
      _fill(0xFF3A2A20),
    );
    canvas.drawPath(
      parseSvgPath('M40 54q8 6 16 0'),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9E5A3E),
    );
    canvas.drawCircle(const Offset(41, 45), 2, _fill(0xFF2A1C14));
    canvas.drawCircle(const Offset(55, 45), 2, _fill(0xFF2A1C14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
