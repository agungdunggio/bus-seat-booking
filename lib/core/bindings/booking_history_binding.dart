import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';
import 'package:bus_seat_booking/domain/usecases/calculate_total_revenue_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/filter_bookings_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_bookings_sorted_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/group_bookings_by_date_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_bookings_changes_usecase.dart';
import 'package:bus_seat_booking/presentation/booking_history/controller/booking_history_controller.dart';
import 'package:get/get.dart';

class BookingHistoryBinding extends Bindings {
  @override
  void dependencies() {

    final repo = Get.find<IBookingRepository>();

    Get.lazyPut(() => GetBookingsSortedUseCase(repo), fenix: true);
    Get.lazyPut(() => CalculateTotalRevenueUseCase(), fenix: true);
    Get.lazyPut(() => FilterBookingsUseCase(), fenix: true);
    Get.lazyPut(() => GroupBookingsByDateUseCase(), fenix: true);

    Get.lazyPut(
      () => BookingHistoryController(
        Get.find<GetBookingsSortedUseCase>(),
        Get.find<WatchBookingsChangesUseCase>(),
        Get.find<CalculateTotalRevenueUseCase>(),
        Get.find<FilterBookingsUseCase>(),
        Get.find<GroupBookingsByDateUseCase>(),
        
      ),
    );
  }
}