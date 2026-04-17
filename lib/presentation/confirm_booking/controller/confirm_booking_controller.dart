import 'package:bus_seat_booking/domain/usecases/execute_booking_usecase.dart';
import 'package:bus_seat_booking/domain/entities/booking_notification_payload.dart';
import 'package:bus_seat_booking/domain/usecases/find_seat_conflicts_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/send_booking_notification_usecase.dart';
import 'package:bus_seat_booking/presentation/widgets/bottom_toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/presentation/confirm_booking/arguments/confirm_booking_args.dart';

enum ConfirmBookingState { idle, loading, success, error }

class ConfirmBookingController extends GetxController {
  ConfirmBookingController(
    this._executeBooking,
    this._findConflicts,
    this._getReservedSeats,
    this._sendNotification,
  );

  final ExecuteBookingUseCase _executeBooking;
  final FindSeatConflictsUseCase _findConflicts;
  final GetReservedSeatsUseCase _getReservedSeats;
  final SendBookingNotificationUseCase _sendNotification;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  final state = ConfirmBookingState.idle.obs;
  final errorMessage = RxnString();
  final hasValidArgs = false.obs;

  late final ConfirmBookingArgs args;

  List<String> findSeatConflicts() {
    return _findConflicts(
      selectedSeatOrder: List<String>.from(args.seatIds),
      reservedSeatIds: reservedForCurrentService,
    );
  }

    Set<String> get reservedForCurrentService =>
      _getReservedSeats(args.bookingDate, args.service);



  bool get isLoading => state.value == ConfirmBookingState.loading;

  @override
  void onInit() {
    super.onInit();
    final routeArgs = Get.arguments;
    if (routeArgs is! ConfirmBookingArgs) {
      state.value = ConfirmBookingState.error;
      errorMessage.value = 'Data booking tidak valid.';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BottomToast.show(
          message: errorMessage.value!,
          type: BottomToastType.error,
        );
        Get.back();
      });
      return;
    }
    args = routeArgs;
    hasValidArgs.value = true;
  }

  Future<void> confirmBooking() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid || isLoading) return;

    final conflicts = findSeatConflicts();
    if (conflicts.isNotEmpty) {
      BottomToast.show(
        message: 'Kursi ini sudah tidak tersedia: ${conflicts.join(', ')}',
        type: BottomToastType.error,
      );
      return;
    }

    state.value = ConfirmBookingState.loading;
    errorMessage.value = null;

    try {
      final result = await _executeBooking(
        bookingDate: args.bookingDate,
        service: args.service,
        seatIds: args.seatIds,
        totalPrice: args.totalPrice,
        passengerName: nameController.text,
        passengerAddress: addressController.text,
      );
      await _sendNotification(
        BookingNotificationPayload(
          seatIds: args.seatIds,
          serviceName: args.service.name,
          bookingDateIso: args.bookingDate.toIso8601String(),
        ),
      );

      state.value = ConfirmBookingState.success;

      Get.back(result: result);
    } catch (e) {
      state.value = ConfirmBookingState.error;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      BottomToast.show(
        message: errorMessage.value ?? 'Terjadi kesalahan.',
        type: BottomToastType.error,
      ); 
    } finally {
      if (state.value != ConfirmBookingState.success) {
        state.value = ConfirmBookingState.idle;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
