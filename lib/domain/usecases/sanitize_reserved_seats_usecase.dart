import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class SanitizeReservedSeatsUseCase {
  SanitizeReservedSeatsUseCase(this._repository);

  final IBookingRepository _repository;

  Future<void> call(DateTime bookingDate, BusServiceType service) async {
    await _repository.sanitizeOrResetReservedSeats(bookingDate, service);
  }
}
