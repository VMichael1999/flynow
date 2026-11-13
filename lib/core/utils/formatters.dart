import 'package:intl/intl.dart';

/// Fecha de referencia del prototipo: hoy es jueves 3 de septiembre de 2026.
final DateTime kToday = DateTime(2026, 9, 3);
final DateTime kDepartureDate = DateTime(2026, 9, 4);

abstract final class Money {
  /// `137` → `$137.00`.
  static String format(num value) => '\$${value.toStringAsFixed(2)}';

  /// `18` → `$18`.
  static String whole(num value) => '\$${value.toStringAsFixed(0)}';
}

abstract final class Fmt {
  static const _months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// «vie» o «Vie» según `capital`.
  static String weekdayShort(DateTime d, {bool capital = false}) {
    final w = DateFormat.E('es').format(d).replaceAll('.', '');
    return capital ? _cap(w) : w;
  }

  static String monthShort(DateTime d) => _months[d.month - 1];

  /// «Vie, 4 sep».
  static String dayMonth(DateTime d) =>
      '${weekdayShort(d, capital: true)}, ${d.day} ${monthShort(d)}';

  /// «vie, 4 sep».
  static String dayMonthLower(DateTime d) =>
      '${weekdayShort(d)}, ${d.day} ${monthShort(d)}';

  /// «VIE 4 SEP».
  static String stubDate(DateTime d) =>
      '${weekdayShort(d)} ${d.day} ${monthShort(d)}'.toUpperCase();

  /// «04 sep 2026».
  static String fullDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${monthShort(d)} ${d.year}';

  /// «4 sep».
  static String shortDate(DateTime d) => '${d.day} ${monthShort(d)}';

  /// 24 horas: «08:50».
  static String time(DateTime d) => DateFormat('HH:mm').format(d);

  /// 110 min → «1h 50m».
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h == 0 ? '${m}m' : '${h}h ${m}m';
  }
}
