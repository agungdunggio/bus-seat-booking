import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/entities/booking_history_filter_type.dart';

class FilterBookingsUseCase {
  List<Booking> call({
    required List<Booking> bookings,
    required BookingHistoryFilterType filter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return bookings.where((b) {
      final created = DateTime(b.createdAt.year, b.createdAt.month, b.createdAt.day);
      
      switch (filter) {
        case BookingHistoryFilterType.all:
          return true;
        case BookingHistoryFilterType.today:
          return created == today;
        case BookingHistoryFilterType.last7Days:
          final start = today.subtract(const Duration(days: 6));
          return !created.isBefore(start) && !created.isAfter(today);
        case BookingHistoryFilterType.last30Days:
          final start = today.subtract(const Duration(days: 29));
          return !created.isBefore(start) && !created.isAfter(today);
        case BookingHistoryFilterType.custom:
          if (customStart == null || customEnd == null) return true;
          return !created.isBefore(customStart) && !created.isAfter(customEnd);
      }
    }).toList();
  }
}