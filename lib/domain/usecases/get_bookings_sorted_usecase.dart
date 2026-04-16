import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class GetBookingsSortedUseCase {
  GetBookingsSortedUseCase(this._repository);

  final IBookingRepository _repository;

  List<Booking> call() {
    return _repository.getBookingsSortedNewest();
  }
}
