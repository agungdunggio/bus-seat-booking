import 'package:bus_seat_booking/domain/entities/booking_entity.dart';

class CalculateTotalRevenueUseCase {
  int call(List<Booking> bookings) {
    var total = 0;
    for (final b in bookings) {
      total += b.totalPrice;
    }
    return total;
  }
}
