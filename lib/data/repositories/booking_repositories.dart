import 'dart:async';

import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bus_seat_booking/data/models/booking_model.dart';
import 'package:bus_seat_booking/domain/entities/booking_entity.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/interface/booking_repository_interface.dart';

class BookingRepository implements IBookingRepository {
  BookingRepository({
    required Box bookingsBox,
    required Box reservedSeatsBox,
  })  : _bookingsBox = bookingsBox,
        _reservedSeatsBox = reservedSeatsBox {
    _reservedSeatsListenable = _reservedSeatsBox.listenable();
    _bookingsListenable = _bookingsBox.listenable();
    _reservedSeatsListenable.addListener(_emitReservedSeatsChanged);
    _bookingsListenable.addListener(_emitBookingsChanged);
    _migrateLegacyReservedIfNeeded();
  }

  final Box _bookingsBox;
  final Box _reservedSeatsBox;
  late final ValueListenable<Box> _reservedSeatsListenable;
  late final ValueListenable<Box> _bookingsListenable;
  final StreamController<void> _reservedSeatsChangedController =
      StreamController<void>.broadcast();
  final StreamController<void> _bookingsChangedController =
      StreamController<void>.broadcast();

  void _emitReservedSeatsChanged() {
    if (!_reservedSeatsChangedController.isClosed) {
      _reservedSeatsChangedController.add(null);
    }
  }

  void _emitBookingsChanged() {
    if (!_bookingsChangedController.isClosed) {
      _bookingsChangedController.add(null);
    }
  }

  static Map<String, List<String>> _emptyServicesMap() => {
        for (final s in BusServiceType.values) s.name: <String>[],
      };

  void _migrateLegacyReservedIfNeeded() {
    final regular = _reservedSeatsBox.get(BusServiceType.regular.name);
    final express = _reservedSeatsBox.get(BusServiceType.express.name);
    if (regular == null && express == null) return;

    final todayKey = bookingDateToStorageKey(DateTime.now());
    final map = _mutableServicesForDateKey(todayKey);
    if (regular is List) {
      map[BusServiceType.regular.name] =
          regular.map((e) => e.toString()).toList();
    }
    if (express is List) {
      map[BusServiceType.express.name] =
          express.map((e) => e.toString()).toList();
    }
    _writeDayMap(todayKey, map);
    _reservedSeatsBox.delete(BusServiceType.regular.name);
    _reservedSeatsBox.delete(BusServiceType.express.name);
  }

  Map<String, List<String>> _mutableServicesForDateKey(String dateKey) {
    final base = _emptyServicesMap();
    final raw = _reservedSeatsBox.get(dateKey);
    if (raw is Map) {
      for (final e in raw.entries) {
        final k = e.key.toString();
        if (!base.containsKey(k)) continue;
        if (e.value is List) {
          base[k] = (e.value as List).map((x) => x.toString()).toList();
        }
      }
    }
    return base;
  }

  void _writeDayMap(String dateKey, Map<String, List<String>> services) {
    _reservedSeatsBox.put(
      dateKey,
      Map<String, dynamic>.from(services),
    );
  }

  @override
  Set<String> getReservedSeats(DateTime bookingDate, BusServiceType service) {
    final key = bookingDateToStorageKey(bookingDate);
    final day = _reservedSeatsBox.get(key);
    if (day is! Map) return {};
    final list = day[service.name];
    if (list is! List) return {};
    return list.map((e) => e.toString()).toSet();
  }

  @override
  Stream<void> watchReservedSeatsChanges() {
    return _reservedSeatsChangedController.stream;
  }

  @override
  Future<bool> sanitizeOrResetReservedSeats(
    DateTime bookingDate,
    BusServiceType service,
  ) async {
    final key = bookingDateToStorageKey(bookingDate);
    final m = _mutableServicesForDateKey(key);
    final current = m[service.name]!.toSet();
    final valid = current.where(service.isValidSeatId).toSet();

    if (valid.length >= service.totalSeats) {
      m[service.name] = [];
      _writeDayMap(key, m);
      return true;
    }

    if (valid.length != current.length) {
      m[service.name] = valid.toList()..sort();
      _writeDayMap(key, m);
      return true;
    }

    return false;
  }

  @override
  Future<void> sanitizeAllReservedSeatsInBox() async {
    _migrateLegacyReservedIfNeeded();
    for (final key in _reservedSeatsBox.keys.toList()) {
      final ks = key.toString();
      if (!isBookingDateStorageKey(ks)) continue;
      final date = bookingDateFromStorageKey(ks);
      for (final s in BusServiceType.values) {
        await sanitizeOrResetReservedSeats(date, s);
      }
    }
  }

  @override
  Future<void> reserveSeats({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
  }) async {
    final key = bookingDateToStorageKey(bookingDate);
    final m = _mutableServicesForDateKey(key);
    final merged = {...m[service.name]!, ...seatIds}.toList()..sort();
    m[service.name] = merged;
    _writeDayMap(key, m);
  }

  @override
  Future<bool> reserveSeatsOrResetIfFull({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
  }) async {
    final key = bookingDateToStorageKey(bookingDate);
    final m = _mutableServicesForDateKey(key);
    final current = {...m[service.name]!, ...seatIds}.toList();

    if (current.length >= service.totalSeats) {
      m[service.name] = [];
      _writeDayMap(key, m);
      return true;
    }

    m[service.name] = current..sort();
    _writeDayMap(key, m);
    return false;
  }

  @override
  Future<void> addBooking({
    required DateTime bookingDate,
    required BusServiceType service,
    required List<String> seatIds,
    required int totalPrice,
    required String passengerName,
    required String passengerAddress,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch;
    final model = BookingModel(
      id: id,
      createdAt: now,
      bookingDate: DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
      ),
      passengerName: passengerName,
      passengerAddress: passengerAddress,
      serviceName: service.name,
      seatIds: seatIds,
      totalPrice: totalPrice,
    );
    await _bookingsBox.put(id.toString(), model.toMap());
  }

  @override
  List<Booking> getBookingsSortedNewest() {
    final items = <Booking>[];
    for (final key in _bookingsBox.keys) {
      final v = _bookingsBox.get(key);
      if (v is Map) {
        final map = v.map((k, val) => MapEntry(k.toString(), val));
        items.add(BookingModel.fromMap(map).toEntity());
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Stream<void> watchBookingsChanges() {
    return _bookingsChangedController.stream;
  }
}
