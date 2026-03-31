import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/utils/constants.dart';

/// Syncs shortcut data to the Android home screen widget.
class WidgetService {
  /// Push the current list of shortcuts to the native widget.
  static Future<void> syncToWidget(List<LocationShortcut> shortcuts) async {
    // Limit to the max number the widget can display
    final widgetShortcuts = shortcuts.take(kMaxWidgetShortcuts).toList();
    final jsonString = jsonEncode(widgetShortcuts.map((s) => s.toJson()).toList());

    await HomeWidget.saveWidgetData<String>(kWidgetDataKey, jsonString);
    await HomeWidget.updateWidget(
      androidName: kWidgetName,
    );
  }
}
