import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/app/app.dart';
import 'package:flynow/app/di.dart';
import 'package:flynow/app/router.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Carga las fuentes empaquetadas (las pruebas no las cargan solas).
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }

  await load('PlusJakartaSans', [
    'PlusJakartaSans-400.ttf',
    'PlusJakartaSans-500.ttf',
    'PlusJakartaSans-600.ttf',
    'PlusJakartaSans-700.ttf',
    'PlusJakartaSans-800.ttf',
  ]);
  await load('KaushanScript', ['KaushanScript-400.ttf']);
}

/// Lienzo del prototipo: 440 × 956 px lógicos.
void useDesignSurface(WidgetTester t) {
  t.view.physicalSize = const Size(440, 956);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

/// Desmonta la app y cierra los BLoCs (si no, quedan temporizadores pendientes).
Future<void> disposeApp(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.runAsync(getIt.reset);
  await t.pump();
}

Future<void> pumpApp(WidgetTester t, {String route = '/home'}) async {
  await t.runAsync(() async {
    await initializeDateFormatting('es');
    await setupDi();
  });
  useDesignSurface(t);
  await t.pumpWidget(const FlyNowApp());
  appRouter.go(route);
  await t.pump();
  await t.pump(const Duration(milliseconds: 500));
}

/// Textos visibles con su caja global (para comparar con el HTML).
List<Map<String, Object>> dumpTexts(WidgetTester t) {
  final out = <Map<String, Object>>[];
  for (final e in find.byType(RichText).evaluate()) {
    final ro = e.renderObject;
    if (ro is! RenderParagraph || !ro.attached || !ro.hasSize) continue;
    var hidden = false;
    RenderObject? p = ro.parent;
    while (p != null) {
      if (p is RenderOpacity && p.opacity == 0) hidden = true;
      if (p is RenderAnimatedOpacity && p.opacity.value == 0) hidden = true;
      p = p.parent;
    }
    final text = ro.text.toPlainText().replaceAll('​', '');
    if (hidden || text.trim().isEmpty) continue;
    final r = ro.localToGlobal(Offset.zero) & ro.size;
    out.add({
      'text': text,
      'x': r.left,
      'y': r.top,
      'w': r.width,
      'h': r.height,
    });
  }
  return out;
}
