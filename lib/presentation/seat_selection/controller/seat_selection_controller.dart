import 'dart:async';

import 'package:bus_seat_booking/core/navigation/app_routes.dart';
import 'package:bus_seat_booking/domain/entities/price_breakdown.dart';
import 'package:bus_seat_booking/domain/usecases/execute_booking_usecase.dart';
import 'package:bus_seat_booking/presentation/widgets/bottom_toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/usecases/calculate_booking_total_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/evaluate_seat_tap_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/find_seat_conflicts_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_invalid_selection_for_service_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/sanitize_all_services_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/sanitize_reserved_seats_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_reserved_seats_changes_usecase.dart';
import 'package:bus_seat_booking/presentation/confirm_booking/arguments/confirm_booking_args.dart';

class SeatSelectionController extends GetxController {
  SeatSelectionController(
    this._getReservedSeats,
    this._watchReservedSeatsChanges,
    this._getInvalidSelection,
    this._evaluateSeatTap,
    this._calculateTotal,
    this._findConflicts,
    this._sanitizeAll,
    this._sanitizeService,
  );

  final GetReservedSeatsUseCase _getReservedSeats;
  final WatchReservedSeatsChangesUseCase _watchReservedSeatsChanges;
  final GetInvalidSelectionForServiceUseCase _getInvalidSelection;
  final EvaluateSeatTapUseCase _evaluateSeatTap;
  final CalculateBookingTotalUseCase _calculateTotal;
  final FindSeatConflictsUseCase _findConflicts;
  final SanitizeAllServicesReservedSeatsUseCase _sanitizeAll;
  final SanitizeReservedSeatsUseCase _sanitizeService;

  final selectedService = BusServiceType.regular.obs;
  final selectedBookingDate = DateUtils.dateOnly(DateTime.now()).obs;
  final selectedSeatOrder = <String>[].obs;

  final hiveReservedTick = 0.obs;

  StreamSubscription<void>? _reservedSeatsSubscription;

  Set<String> get reservedForCurrentService =>
      _getReservedSeats(selectedBookingDate.value, selectedService.value);

  int remainingSeatsFor(DateTime date, BusServiceType service) {
    final reserved = _getReservedSeats(
      DateUtils.dateOnly(date),
      service,
    ).length;
    final remaining = service.totalSeats - reserved;
    return remaining < 0 ? 0 : remaining;
  }

  final priceBreakdown = Rxn<PriceBreakdown>();

  int get totalPrice => priceBreakdown.value?.totalPrice ?? 0;

  DateTime get minBookingDate => DateUtils.dateOnly(DateTime.now());

  DateTime get maxBookingDate =>
      DateUtils.dateOnly(DateTime.now().add(const Duration(days: 365 * 2)));

  @override
  void onInit() {
    super.onInit();
    _reservedSeatsSubscription = _watchReservedSeatsChanges().listen((_) {
      _onReservedChanged();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _sanitizeAll();
    });
    ever(selectedService, (_) => _stripInvalidSeatsDeferred());
    ever(selectedBookingDate, (_) => _onBookingDateChangedDeferred());

    everAll([selectedService, selectedBookingDate, selectedSeatOrder], (_) {
      _recalculatePrice();
    });
  }

  void _onReservedChanged() {
    hiveReservedTick.value++;
  }

  void _recalculatePrice() {
    priceBreakdown.value = _calculateTotal(
      date: selectedBookingDate.value,
      service: selectedService.value,
      seatCount: selectedSeatOrder.length,
    );
  }

  void _onBookingDateChangedDeferred() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _stripSeatsReservedOnThisDate();
      _stripInvalidSeats();
    });
  }

  void _stripSeatsReservedOnThisDate() {
    final reserved = _getReservedSeats(
      selectedBookingDate.value,
      selectedService.value,
    );
    removeSeatsFromSelection(
      selectedSeatOrder.where(reserved.contains).toList(),
    );
  }

  void _stripInvalidSeatsDeferred() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _stripInvalidSeats();
    });
  }

  void sanitizeSelectionIfNeeded() {
    _stripInvalidSeats();
  }

  void _stripInvalidSeats() {
    final invalid = _getInvalidSelection(
      service: selectedService.value,
      selectedSeatIds: selectedSeatOrder.toSet(),
    );
    if (invalid.isEmpty) return;
    for (final s in invalid) {
      selectedSeatOrder.remove(s);
    }
  }

  void onBookingDateChanged(DateTime date) {
    selectedBookingDate.value = DateUtils.dateOnly(date);
  }

  void onBusServiceChanged(BusServiceType value) {
    selectedService.value = value;
    selectedSeatOrder.clear();
    _sanitizeService(selectedBookingDate.value, value);
  }

  void navigateToBookingHistory() {
    Get.toNamed(AppRoutes.bookingHistory);
  }

  void onSeatTap(String seatId) {
    final reserved = reservedForCurrentService;
    final result = _evaluateSeatTap(
      seatId: seatId,
      selectedSeatIds: selectedSeatOrder.toSet(),
      reservedSeatIds: reserved,
    );
    switch (result.action) {
      case SeatTapAction.blocked:
        return;
      case SeatTapAction.remove:
        if (result.seatId != null) {
          selectedSeatOrder.remove(result.seatId);
        }
        return;
      case SeatTapAction.add:
        if (result.seatId != null) {
          selectedSeatOrder.add(result.seatId!);
        }
        return;
    }
  }

  List<String> findSeatConflicts() {
    return _findConflicts(
      selectedSeatOrder: List<String>.from(selectedSeatOrder),
      reservedSeatIds: reservedForCurrentService,
    );
  }

  void removeSeatsFromSelection(List<String> seatIds) {
    for (final s in seatIds) {
      selectedSeatOrder.remove(s);
    }
  }

  Future<void> navigateToConfirmBooking() async {
    sanitizeSelectionIfNeeded();

    if (selectedSeatOrder.isEmpty) {
      BottomToast.show(
        message: 'Silakan pilih minimal 1 kursi terlebih dahulu.',
        type: BottomToastType.info,
      );
      return;
    }

    final conflicts = findSeatConflicts();
    if (conflicts.isNotEmpty) {
      BottomToast.show(
        message: 'Kursi ini sudah tidak tersedia: ${conflicts.join(', ')}',
      );
      removeSeatsFromSelection(conflicts);
      return;
    }

    final dynamic rawResult = await Get.toNamed(
      AppRoutes.confirmBooking,
      arguments: ConfirmBookingArgs(
        bookingDate: selectedBookingDate.value,
        service: selectedService.value,
        seatIds: List<String>.from(selectedSeatOrder),
        totalPrice: totalPrice,
      ),
    );

    final ExecuteBookingResult? result =
        rawResult is ExecuteBookingResult ? rawResult : null;

    if (result == null) return;

    selectedSeatOrder.clear();
    BottomToast.show(
      message: 'Booking berhasil dibuat.',
      type: BottomToastType.success,
    );
    if (result.didResetAllSeats) {
      BottomToast.show(
        message:
            '${selectedService.value.label} sudah penuh, kursi di-reset untuk trip berikutnya.',
        type: BottomToastType.info,
      );
    }
  }

  @override
  void onClose() {
    _reservedSeatsSubscription?.cancel();
    super.onClose();
  }
}
