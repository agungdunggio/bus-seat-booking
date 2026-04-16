// import 'package:flutter/rendering.dart';
import 'package:bus_seat_booking/domain/usecases/execute_booking_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/find_seat_conflicts_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_bookings_changes_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_reserved_seats_changes_usecase.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:bus_seat_booking/data/local/local_boxes.dart';
import 'package:bus_seat_booking/data/repositories/booking_repositories.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    final bookingsBox = Hive.box(LocalBoxes.bookings);
    final reservedBox = Hive.box(LocalBoxes.reservedSeats);

    // void printFull(Object object) {
    //   final str = object.toString();
    //   const chunkSize = 800;

    //   for (var i = 0; i < str.length; i += chunkSize) {
    //     print(str.substring(
    //       i,
    //       i + chunkSize > str.length ? str.length : i + chunkSize,
    //     ));
    //   }
    // }

    // printFull('bookingsBox: ${bookingsBox.toMap()}');
    // printFull('reservedBox: ${reservedBox.toMap()}');

    final repo = Get.put<IBookingRepository>(
      BookingRepository(
        bookingsBox: bookingsBox,
        reservedSeatsBox: reservedBox,
      ),
      permanent: true,
    );

    Get.lazyPut(() => FindSeatConflictsUseCase(), fenix: true);
    Get.lazyPut(() => GetReservedSeatsUseCase(repo), fenix: true  );
    Get.lazyPut(() => WatchReservedSeatsChangesUseCase(repo), fenix: true);
    Get.lazyPut(() => WatchBookingsChangesUseCase(repo), fenix: true);
    Get.lazyPut(() => ExecuteBookingUseCase(repo), fenix: true);

  }
}
