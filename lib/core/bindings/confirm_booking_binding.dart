import 'package:bus_seat_booking/domain/usecases/find_seat_conflicts_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_reserved_seats_usecase.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/domain/usecases/execute_booking_usecase.dart';
import 'package:bus_seat_booking/presentation/confirm_booking/controller/confirm_booking_controller.dart';

class ConfirmBookingBinding extends Bindings {
  @override
  void dependencies() {
    final findSeatConflicts = Get.find<FindSeatConflictsUseCase>();
    final getReservedSeats = Get.find<GetReservedSeatsUseCase>();
    final executeBooking = Get.find<ExecuteBookingUseCase>();
    
    Get.lazyPut(() => ConfirmBookingController(
        executeBooking,
        findSeatConflicts,
        getReservedSeats,
      ),
    );
  }
}
