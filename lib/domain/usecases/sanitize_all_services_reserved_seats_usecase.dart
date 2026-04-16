import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class SanitizeAllServicesReservedSeatsUseCase {
  SanitizeAllServicesReservedSeatsUseCase(this._repository);

  final IBookingRepository _repository;

  Future<void> call() async {
    await _repository.sanitizeAllReservedSeatsInBox();
  }
}
