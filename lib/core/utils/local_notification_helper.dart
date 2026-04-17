import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bus_seat_booking/domain/entities/app_notification.dart';

class LocalNotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> show(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }
}