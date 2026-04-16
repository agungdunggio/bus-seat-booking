import 'package:bus_seat_booking/domain/entities/booking_entity.dart';

class BookingDayGroup {
  const BookingDayGroup({
    required this.date,
    required this.bookings,
  });

  final DateTime date;
  final List<Booking> bookings;
}
