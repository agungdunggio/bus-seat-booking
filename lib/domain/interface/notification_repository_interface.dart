import 'package:bus_seat_booking/domain/entities/app_notification.dart';

abstract class INotificationRepository {
  Future<bool> requestPermission();
  Future<String?> getToken();
  
  Stream<AppNotification> get onForegroundMessage;
  Stream<AppNotification> get onMessageOpenedApp;

  Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}