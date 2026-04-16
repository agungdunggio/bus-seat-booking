import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.createdAt,
    required this.bookingDate,
    required this.passengerName,
    required this.passengerAddress,
    required this.serviceName,
    required this.seatIds,
    required this.totalPrice,
  });

  final int id;
  final DateTime createdAt;
  final DateTime bookingDate;
  final String passengerName;
  final String passengerAddress;
  final String serviceName;
  final List<String> seatIds;
  final int totalPrice;

  factory BookingModel.fromMap(Map<String, Object?> map) {
    final seatsRaw = map['seats'];
    final seats = seatsRaw is List
        ? seatsRaw.map((e) => e.toString()).toList()
        : <String>[];
    final createdAtIso = (map['createdAt'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtIso) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final bookingDateRaw = (map['bookingDate'] ?? '').toString();
    DateTime bookingDate;
    if (bookingDateRaw.isNotEmpty) {
      bookingDate = DateTime.tryParse(bookingDateRaw) ??
          bookingDateFromStorageKey(bookingDateRaw);
    } else {
      bookingDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    }

    final idVal = map['id'];
    final id = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '') ??
            createdAt.microsecondsSinceEpoch;

    return BookingModel(
      id: id,
      createdAt: createdAt,
      bookingDate: DateTime(bookingDate.year, bookingDate.month, bookingDate.day),
      passengerName: (map['name'] ?? '').toString(),
      passengerAddress: (map['address'] ?? '').toString(),
      serviceName: (map['service'] ?? '').toString(),
      seatIds: seats,
      totalPrice: int.tryParse((map['totalPrice'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'bookingDate': bookingDateToStorageKey(bookingDate),
      'name': passengerName,
      'address': passengerAddress,
      'service': serviceName,
      'seats': seatIds,
      'totalPrice': totalPrice,
    };
  }

  Booking toEntity() {
    final service = BusServiceType.values.firstWhere(
      (e) => e.name == serviceName,
      orElse: () => BusServiceType.regular,
    );

    return Booking(
      id: id,
      createdAt: createdAt,
      bookingDate: bookingDate,
      name: passengerName,
      address: passengerAddress,
      service: service,
      seatIds: List<String>.from(seatIds),
      totalPrice: totalPrice,
    );
  }
}
