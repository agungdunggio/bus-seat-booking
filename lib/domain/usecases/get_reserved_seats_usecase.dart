import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class GetReservedSeatsUseCase {
  GetReservedSeatsUseCase(this._repository);

  final IBookingRepository _repository;

  Set<String> call(DateTime bookingDate, BusServiceType service) {
    return _repository.getReservedSeats(bookingDate, service);
  }
}
