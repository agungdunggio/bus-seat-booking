import 'package:bus_seat_booking/core/bindings/booking_history_binding.dart';
import 'package:bus_seat_booking/core/bindings/confirm_booking_binding.dart';
import 'package:bus_seat_booking/core/bindings/seat_selection_binding.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/core/navigation/app_routes.dart';
import 'package:bus_seat_booking/presentation/booking_history/booking_history_screen.dart';
import 'package:bus_seat_booking/presentation/confirm_booking/confirm_booking_screen.dart';
import 'package:bus_seat_booking/presentation/seat_selection/selection_seat_screen.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.seatSelection,
      page: () => const SelectionSeatPage(),
      binding: SeatSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingHistory,
      page: () => const BookingHistoryScreen(),
      binding: BookingHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.confirmBooking,
      page: () => const ConfirmBookingScreen(),
      binding: ConfirmBookingBinding(),
    ),
  ];
}
