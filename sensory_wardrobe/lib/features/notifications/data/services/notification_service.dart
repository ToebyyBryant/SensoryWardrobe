import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// P7.0 — Manage Notifications & Reminders
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  /// Schedule a daily morning reminder to log today's outfit.
  Future<void> scheduleMorningReminder(int hour, int minute) async {
    // TODO: Implement with timezone package for exact scheduling
  }

  /// Schedule a daily evening reminder to rate today's outfit comfort.
  Future<void> scheduleEveningRatingReminder(int hour, int minute) async {
    // TODO: Implement with timezone package for exact scheduling
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sensory_wardrobe_channel',
      'Sensory Wardrobe',
      channelDescription: 'Outfit and comfort reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }
}
