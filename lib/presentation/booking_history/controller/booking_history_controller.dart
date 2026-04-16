import 'dart:async';

import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/booking_history_filter_type.dart';
import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/usecases/filter_bookings_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/group_bookings_by_date_usecase.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/domain/entities/booking_day_group.dart';
import 'package:bus_seat_booking/domain/usecases/calculate_total_revenue_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/get_bookings_sorted_usecase.dart';
import 'package:bus_seat_booking/domain/usecases/watch_bookings_changes_usecase.dart';



class BookingHistoryController extends GetxController {
  BookingHistoryController(
    this._getBookingsSorted,
    this._watchBookingsChanges,
    this._totalRevenue,
    this._filterBookings,
    this._groupBookingsByDate,
  );

  final GetBookingsSortedUseCase _getBookingsSorted;
  final WatchBookingsChangesUseCase _watchBookingsChanges;
  final CalculateTotalRevenueUseCase _totalRevenue;
  final FilterBookingsUseCase _filterBookings;
  final GroupBookingsByDateUseCase _groupBookingsByDate;

  StreamSubscription<void>? _bookingsSubscription;

  final dayGroups = <BookingDayGroup>[].obs;
  final totalRevenue = 0.obs;
  final selectedFilter = BookingHistoryFilterType.all.obs;
  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();

  List<Booking> _allBookings = const [];

  @override
  void onInit() {
    super.onInit();
    _bookingsSubscription = _watchBookingsChanges().listen((_) {
      _onBookingsChanged();
    });
    _refresh();
  }

  void _onBookingsChanged() {
    _refresh();
  }

  void _refresh() {
    _allBookings = _getBookingsSorted();
    _applyFilterAndGroup();
  }

  void setFilter(BookingHistoryFilterType filter) {
    selectedFilter.value = filter;
    if (filter != BookingHistoryFilterType.custom) {
      customStartDate.value = null;
      customEndDate.value = null;
    }
    _applyFilterAndGroup();
  }

  void setCustomRange(DateTime start, DateTime end) {
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    if (endOnly.isBefore(startOnly)) return;
    customStartDate.value = startOnly;
    customEndDate.value = endOnly;
    selectedFilter.value = BookingHistoryFilterType.custom;
    _applyFilterAndGroup();
  }

  void _applyFilterAndGroup() {
    final filtered = _filterBookings(
      bookings: _allBookings,
      filter: selectedFilter.value,
      customStart: customStartDate.value,
      customEnd: customEndDate.value,
    );
    
    dayGroups.assignAll(_groupBookingsByDate(filtered));
    
    totalRevenue.value = _totalRevenue(filtered);
  }

  String get customRangeLabel {
    final start = customStartDate.value;
    final end = customEndDate.value;
    if (start == null || end == null) return 'Range';
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  @override
  void onClose() {
    _bookingsSubscription?.cancel();
    super.onClose();
  }
}
