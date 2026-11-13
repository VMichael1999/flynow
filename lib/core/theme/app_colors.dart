import 'package:flutter/material.dart';

/// Tokens de color del prototipo. Es el único lugar donde se escriben colores.
abstract final class AppColors {
  static const navy900 = Color(0xFF0D0F29);
  static const navy800 = Color(0xFF131C4D);
  static const navy700 = Color(0xFF1B2A6E);
  static const navy = Color(0xFF1E2970);
  static const primary = Color(0xFF22348F);
  static const primaryBright = Color(0xFF2B42A8);

  static const ink = Color(0xFF13163A);
  static const ink2 = Color(0xFF6D7290);
  static const ink3 = Color(0xFFA2A6BC);
  static const line = Color(0xFFE7E9F2);
  static const background = Color(0xFFF1F2F9);
  static const field = Color(0xFFF2F4FA);
  static const tint = Color(0xFFE9ECF8);
  static const cityBlue = Color(0xFF2F3E9E);
  static const route = Color(0xFF5BC0DE);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const green = Color(0xFF1FA463);
  static const greenSoft = Color(0xFFE1F5EA);
  static const red = Color(0xFFE0504A);
  static const redSoft = Color(0xFFFDECEB);
  static const amber = Color(0xFFF2B53A);

  static const seatTaken = Color(0xFFE3E6EF);
  static const seatTakenEdge = Color(0xFFD6DAE6);
  static const seatFreeBorder = Color(0xFFCED2E2);
  static const seatFreeEdge = Color(0xFFE4E7F1);
  static const seatFreeText = Color(0xFF7C819B);
  static const seatExtra = Color(0xFFD8F0FA);
  static const seatExtraBorder = Color(0xFF8ACFEA);
  static const seatExtraEdge = Color(0xFFB8E3F4);
  static const seatExtraText = Color(0xFF2A87B4);
  static const seatSelectedEdge = Color(0xFF172475);

  static const checkInPillBg = Color(0xFFDFF2FA);
  static const checkInPillFg = Color(0xFF1E7EA8);

  // Auxiliares sacados del <style> del prototipo.
  static const stepPending = Color(0xFFDDE0EE);
  static const divider = Color(0xFFE1E4EF);
  static const rowDivider = Color(0xFFF0F1F7);
  static const perforation = Color(0xFFCDD2E2);
  static const boardingPerforation = Color(0xFFC9CEDF);
  static const mapLand = Color(0xFFECEFF7);
  static const grabHandle = Color(0xFFE3E5EE);
  static const socialBorder = Color(0xFFE3E5EE);
  static const loginFocus = Color(0xFF2E3A86);
  static const fieldIcon = Color(0xFF7C819B);
  static const placeholder = Color(0xFF9EA2B8);
  static const checkboxBorder = Color(0xFFC7CADB);
  static const switchOff = Color(0xFFD6D9E6);
  static const statusChip = Color(0xFFE8EBF6);
  static const logoutBorder = Color(0xFFF2C9C6);
  static const dashRoute = Color(0xFFC3C8DC);
  static const routeEnd = Color(0xFF3A57C8);
  static const routeEndHollow = Color(0xFF9AA0BC);
  static const barcode = Color(0xFF1B1D2E);
  static const barcodeVertical = Color(0xFF14162A);
  static const googleBlue = Color(0xFF4285F4);
  static const ticketRed1 = Color(0xFFD92A23);
  static const ticketRed2 = Color(0xFFEE3B32);
  static const ticketBlue1 = Color(0xFF151D5C);
  static const ticketBlue2 = Color(0xFF1F2C7C);
  static const ticketNotch = Color(0xFF3A57C8);

  // Pase de abordar
  static const bpMap = Color(0x338296FF);
  static const bpPlane = Color(0xFF3E8BFF);
  static const bpLabel = Color(0xFF9AA6E8);
  static const bpAmPm = Color(0xFF5B9BFF);
  static const bpCity = Color(0xFFB4BCEB);
  static const bpDot = Color(0xFFB9C4F5);
  static const bpStubLabel = Color(0xFF7D84A3);
  static const bpSeatBorder = Color(0xFF2A3780);
  static const bpSeatFill = Color(0xFFEBEEFB);

  // Splash / mapas / arcos
  static const trailStart = Color(0x005BC0DE);
  static const trailEnd = Color(0xFFBFE3FF);
  static const trailHead = Color(0xFF9FDDFF);
  static const planeHalo = Color(0xFFBFE6FF);
  static const homeDots = Color(0xFF8EA2F5);
  static const topStrip = Color(0xFF141A49);
  static const lightBarrier = Color(0xFFF4F5FB);
  static const pullSpinner = Color(0xFFD7F0F8);
  static const navInactive = Color(0xFF4A4F6E);
  static const photoBg = Color(0xFFDCE1F2);
  static const fareSelectedBg = Color(0xFFFAFBFF);
  static const ringTrack = Color(0xFFE3E6F0);
  static const transparent = Color(0x00000000);
  static const brandArc = Color(0xD9A0CDFF);
  static const heroSky1 = Color(0xFFDCEBFA);
  static const heroSky2 = Color(0xFFEEF4FC);
}

/// Los mismos tokens, expuestos como extensión del tema.
@immutable
class SkyPalette extends ThemeExtension<SkyPalette> {
  const SkyPalette();

  Color get primary => AppColors.primary;
  Color get ink => AppColors.ink;
  Color get ink2 => AppColors.ink2;
  Color get ink3 => AppColors.ink3;
  Color get line => AppColors.line;
  Color get background => AppColors.background;
  Color get field => AppColors.field;
  Color get tint => AppColors.tint;

  @override
  SkyPalette copyWith() => const SkyPalette();

  @override
  SkyPalette lerp(ThemeExtension<SkyPalette>? other, double t) => this;
}

extension SkyPaletteX on BuildContext {
  SkyPalette get sky => Theme.of(this).extension<SkyPalette>()!;
}
