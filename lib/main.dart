import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/utils/constants.dart';
import 'package:location_shortcut_widget/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(LocationShortcutAdapter());
  await Hive.openBox<LocationShortcut>(kHiveBoxName);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
