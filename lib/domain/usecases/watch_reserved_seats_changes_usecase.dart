import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class WatchReservedSeatsChangesUseCase {
  WatchReservedSeatsChangesUseCase(this._repository);

  final IBookingRepository _repository;

  Stream<void> call() => _repository.watchReservedSeatsChanges();
}
