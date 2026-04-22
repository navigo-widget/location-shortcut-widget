import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/expiry_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules and cancels local notifications for shortcut expiry warnings.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'navigo_expiry';
  static const _channelName = 'Expiry Warnings';
  static const _channelDesc =
      'Notifies you when a saved location is about to expire';

  /// Call once at app startup before runApp.
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Request POST_NOTIFICATIONS permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Stable int ID derived from the shortcut's UUID.
  static int _notifId(String shortcutId) =>
      shortcutId.hashCode.abs() % 100000;

  /// Schedule a warning notification for [shortcut] if it has an expiry.
  /// Safe to call even when expiresAt is null — it's a no-op in that case.
  static Future<void> scheduleExpiryWarning(LocationShortcut shortcut) async {
    final expiresAt = shortcut.expiresAt;
    if (expiresAt == null) return;

    // Infer warning threshold from the original expiry duration
    final totalDays = expiresAt.difference(shortcut.createdAt).inDays;
    final option = totalDays <= 4
        ? ExpiryOption.threeDays
        : totalDays <= 10
            ? ExpiryOption.oneWeek
            : totalDays <= 45
                ? ExpiryOption.oneMonth
                : ExpiryOption.oneYear;

    final warningTime =
        expiresAt.subtract(Duration(days: option.warningDays));

    // Don't schedule if the warning time has already passed
    if (warningTime.isBefore(DateTime.now())) return;

    final daysLeft = expiresAt.difference(DateTime.now()).inDays;
    final body = daysLeft <= 1
        ? '"${shortcut.label}" expires today — navigate before it\'s gone.'
        : '"${shortcut.label}" expires in $daysLeft days.';

    await _plugin.zonedSchedule(
      _notifId(shortcut.id),
      'Shortcut expiring soon',
      body,
      tz.TZDateTime.from(warningTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel any pending notification for this shortcut (call on delete/update).
  static Future<void> cancel(String shortcutId) async {
    await _plugin.cancel(_notifId(shortcutId));
  }

  /// Cancel all pending NaviGo notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
