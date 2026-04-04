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

  /// Check if Android App Links are verified for our domain.
  /// When verified, shared links open NaviGo directly (no browser).
  static Future<bool> isAppLinkVerified() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAppLinkVerified');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Open the system "Open by default" settings for this app.
  static Future<void> openAppLinkSettings() async {
    try {
      await _channel.invokeMethod<bool>('openAppLinkSettings');
    } on PlatformException {
      // Ignore — older Android versions don't support this
    }
  }

  /// Get the signing fingerprint of the installed APK (for assetlinks.json).
  static Future<String?> getSigningFingerprint() async {
    try {
      return await _channel.invokeMethod<String>('getSigningFingerprint');
    } on PlatformException {
      return null;
    }
  }
}
