import 'package:bus_seat_booking/domain/entities/booking_day_group.dart';
import 'package:bus_seat_booking/domain/entities/booking_entity.dart';

class GroupBookingsByDateUseCase {
  List<BookingDayGroup> call(List<Booking> bookings) {
    final grouped = <DateTime, List<Booking>>{};
    for (final b in bookings) {
      final d = b.createdAt;
      final dateOnly = DateTime(d.year, d.month, d.day);
      grouped.putIfAbsent(dateOnly, () => []).add(b);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final byBookingDate = a.bookingDate.compareTo(b.bookingDate);
        if (byBookingDate != 0) return byBookingDate;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in sortedDates)
        BookingDayGroup(date: day, bookings: grouped[day] ?? []),
    ];
  }
}
