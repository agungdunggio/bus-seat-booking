import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

abstract class IBookingRepository {
  Set<String> getReservedSeats(DateTime bookingDate, BusServiceType service);

  Stream<void> watchReservedSeatsChanges();

  Future<bool> sanitizeOrResetReservedSeats(
    DateTime bookingDate,
    BusServiceType service,
  );

  Future<void> sanitizeAllReservedSeatsInBox();

  Future<void> reserveSeats({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
  });

  Future<bool> reserveSeatsOrResetIfFull({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
  });

  Future<void> addBooking({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
    required int totalPrice,
    required String passengerName,
    required String passengerAddress,
  });

  List<Booking> getBookingsSortedNewest();

  Stream<void> watchBookingsChanges();
}
