import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

class ConfirmBookingArgs {
  const ConfirmBookingArgs({
    required this.bookingDate,
    required this.service,
    required this.seatIds,
    required this.totalPrice,
  });

  final DateTime bookingDate;
  final BusServiceType service;
  final List<String> seatIds;
  final int totalPrice;
}
