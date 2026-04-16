import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class ExecuteBookingResult {
  const ExecuteBookingResult({
    required this.didResetAllSeats,
  });

  final bool didResetAllSeats;
}

class ExecuteBookingUseCase {
  ExecuteBookingUseCase(this._repository);

  final IBookingRepository _repository;

  Future<ExecuteBookingResult> call({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
    required int totalPrice,
    required String passengerName,
    required String passengerAddress,
  }) async {
    await _repository.addBooking(
      bookingDate: bookingDate,
      service: service,
      seatIds: seatIds,
      totalPrice: totalPrice,
      passengerName: passengerName,
      passengerAddress: passengerAddress,
    );
    final didReset = await _repository.reserveSeatsOrResetIfFull(
      bookingDate: bookingDate,
      service: service,
      seatIds: seatIds,
    );
    return ExecuteBookingResult(didResetAllSeats: didReset);
  }
}
