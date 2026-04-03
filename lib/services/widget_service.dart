import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/widget_style_provider.dart';
import 'package:navigo/utils/constants.dart';

/// Syncs shortcut data to the Android home screen widget.
class WidgetService {
  static const _channel = MethodChannel('com.navigo.app/widget');

  /// Push the current list of shortcuts to the native widget.
  static Future<void> syncToWidget(
    List<LocationShortcut> shortcuts, {
    WidgetStyle style = WidgetStyle.frostedGlass,
  }) async {
    final widgetShortcuts = shortcuts.take(kMaxWidgetShortcuts).toList();
    final jsonString =
        jsonEncode(widgetShortcuts.map((s) => s.toJson()).toList());

    await HomeWidget.saveWidgetData<String>(kWidgetDataKey, jsonString);
    await HomeWidget.saveWidgetData<String>(
      kWidgetStyleKey,
      style == WidgetStyle.boldColors ? 'boldColors' : 'frostedGlass',
    );
    await HomeWidget.updateWidget(
      androidName: kWidgetName,
    );
  }

  /// Request the system to pin the NaviGo widget to the home screen.
  static Future<bool> requestPinWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPinWidget');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Check if the NaviGo widget is currently on the home screen.
  static Future<bool> isWidgetPinned() async {
    try {
      final result = await _channel.invokeMethod<bool>('isWidgetPinned');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
