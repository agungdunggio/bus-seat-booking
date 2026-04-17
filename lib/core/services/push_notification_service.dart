import 'package:bus_seat_booking/core/utils/local_notification_helper.dart';
import 'package:get/get.dart';
import 'package:bus_seat_booking/domain/interface/notification_repository_interface.dart';

class PushNotificationService extends GetxService {
  PushNotificationService(this._repository);

  final INotificationRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    final hasPermission = await _repository.requestPermission();
    if (!hasPermission) {
      return;
    }

    _repository.onForegroundMessage.listen((message) {
      LocalNotificationHelper.show(message);
    });
  }
}