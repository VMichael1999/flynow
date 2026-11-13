import 'package:flutter/material.dart';

import '../widgets/svg_path.dart';

/// Imagen de cabecera del login (440 × 330, recortada para cubrir el ancho).
class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  static const asset = 'assets/images/login_hero.jpg';

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: double.infinity,
    height: 330,
    child: Image(
      image: AssetImage(asset),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      excludeFromSemantics: true,
    ),
  );
}

Paint _fill(int argb) => Paint()..color = Color(argb);

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
