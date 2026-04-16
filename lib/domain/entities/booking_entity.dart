import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

class Booking {
  const Booking({
    required this.id,
    required this.createdAt,
    required this.bookingDate,
    required this.name,
    required this.address,
    required this.service,
    required this.seatIds,
    required this.totalPrice,
  });

  final int id;
  final DateTime createdAt;
  final DateTime bookingDate;
  final String name;
  final String address;
  final BusServiceType service;
  final List<String> seatIds;
  final int totalPrice;
}
