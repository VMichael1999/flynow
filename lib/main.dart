import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await setupDi();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FlyNowApp());
}
