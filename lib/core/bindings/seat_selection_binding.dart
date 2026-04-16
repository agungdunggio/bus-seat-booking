import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';
import 'package:bus_seat_booking/domain/usecases/calculate_booking_total_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/evaluate_seat_tap_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/find_seat_conflicts_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_invalid_selection_for_service_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/sanitize_all_services_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/sanitize_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_reserved_seats_changes_usecase.dart';
import 'package:bus_seat_booking/presentation/seat_selection/controller/seat_selection_controller.dart';
import 'package:get/get.dart';

class SeatSelectionBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<IBookingRepository>();
    final findSeatConflicts = Get.find<FindSeatConflictsUseCase>();
    final getReservedSeats = Get.find<GetReservedSeatsUseCase>();
    final watchReservedSeatsChanges = Get.find<WatchReservedSeatsChangesUseCase>();


    Get.lazyPut(() => SanitizeAllServicesReservedSeatsUseCase(repo), fenix: true);
    Get.lazyPut(() => SanitizeReservedSeatsUseCase(repo), fenix: true);
    Get.lazyPut(() => GetInvalidSelectionForServiceUseCase(), fenix: true);
    Get.lazyPut(() => EvaluateSeatTapUseCase(), fenix: true);
    Get.lazyPut(() => CalculateBookingTotalUseCase(), fenix: true);

    Get.lazyPut(
      () => SeatSelectionController(
        getReservedSeats,
        watchReservedSeatsChanges,
        Get.find<GetInvalidSelectionForServiceUseCase>(),
        Get.find<EvaluateSeatTapUseCase>(),
        Get.find<CalculateBookingTotalUseCase>(),
        findSeatConflicts,
        Get.find<SanitizeAllServicesReservedSeatsUseCase>(),
        Get.find<SanitizeReservedSeatsUseCase>(),
      ),
    );
  }
}
