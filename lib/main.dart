import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/services/notification_service.dart';
import 'package:navigo/utils/constants.dart';
import 'package:navigo/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(LocationShortcutAdapter());
  await Hive.openBox<LocationShortcut>(kHiveBoxName);

  // Initialize local notifications (requests permission on Android 13+)
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
