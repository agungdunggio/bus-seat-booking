import 'package:bus_seat_booking/domain/entities/booking_notification_payload.dart';
import 'package:bus_seat_booking/domain/interface/notification_repository_interface.dart';
import 'package:flutter/foundation.dart';

class SendBookingNotificationUseCase {
  SendBookingNotificationUseCase(this._notificationRepo);

  final INotificationRepository _notificationRepo;

  Future<void> call(BookingNotificationPayload payload) async {
    final token = await _notificationRepo.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await _notificationRepo.sendNotification(
        targetToken: token,
        title: 'Booking Berhasil',
        body:
            'Seat ${payload.seatIds.join(', ')} untuk ${payload.serviceName} berhasil dipesan.',
        data: <String, dynamic>{
          'type': 'booking_success',
          'booking_date': payload.bookingDateIso,
          'service': payload.serviceName,
        },
      );
    } catch (e) {
      debugPrint('Gagal mengirim notifikasi: $e');
    }
  }
}
