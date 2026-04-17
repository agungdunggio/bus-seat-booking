import 'dart:async';

import 'package:bus_seat_booking/domain/entities/app_notification.dart';
import 'package:bus_seat_booking/domain/interface/notification_repository_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  NotificationController(this._notificationRepo);

  final INotificationRepository _notificationRepo;

  final fcmToken = ''.obs;
  final latestNotification = Rxn<AppNotification>();

  late final StreamSubscription _foregroundSub;

  @override
  void onInit() {
    super.onInit();
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    final token = await _notificationRepo.getToken();
    fcmToken.value = token ?? '';

    _foregroundSub = _notificationRepo.onForegroundMessage.listen(_onMessageReceived);
  }

  void _onMessageReceived(AppNotification notification) {
    latestNotification.value = notification;
    debugPrint('Foreground notification: ${notification.title}');
  }

  @override
  void onClose() {
    _foregroundSub.cancel();
    super.onClose();
  }

}
