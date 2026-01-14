import 'package:hive/hive.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';

class BookingLocalRepository {
  BookingLocalRepository({
    required Box bookingsBox,
    required Box reservedSeatsBox,
  })  : _bookingsBox = bookingsBox,
        _reservedSeatsBox = reservedSeatsBox;

  final Box _bookingsBox;
  final Box _reservedSeatsBox;

  static String _reservedKey(BusService service) => service.name;

  Set<String> getReservedSeats(BusService service) {
    final value = _reservedSeatsBox.get(_reservedKey(service));
    final list = (value is List) ? value : const <dynamic>[];
    return list.map((e) => e.toString()).toSet();
  }

  Future<bool> sanitizeOrResetReservedSeats(BusService service) async {
    final current = getReservedSeats(service);
    final valid = current.where(service.isValidSeatId).toSet();

    if (valid.length >= service.totalSeats) {
      await _reservedSeatsBox.put(_reservedKey(service), <String>[]);
      return true;
    }

    if (valid.length != current.length) {
      await _reservedSeatsBox.put(_reservedKey(service), valid.toList()..sort());
      return true;
    }

    return false;
  }

  Future<void> reserveSeats({
    required BusService service,
    required List<String> seatIds,
  }) async {
    final current = getReservedSeats(service);
    current.addAll(seatIds);
    await _reservedSeatsBox.put(_reservedKey(service), current.toList()..sort());
  }

  Future<bool> reserveSeatsOrResetIfFull({
    required BusService service,
    required List<String> seatIds,
  }) async {
    final current = getReservedSeats(service);
    current.addAll(seatIds);

    if (current.length >= service.totalSeats) {
      await _reservedSeatsBox.put(_reservedKey(service), <String>[]);
      return true;
    }

    await _reservedSeatsBox.put(_reservedKey(service), current.toList()..sort());
    return false;
  }

  Future<void> addBooking({
    required BusService service,
    required List<String> seatIds,
    required int totalPrice,
  }) async {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}';
    await _bookingsBox.put(id, {
      'id': id,
      'createdAt': now.toIso8601String(),
      'service': service.name,
      'seats': seatIds,
      'totalPrice': totalPrice,
    });
  }

  List<Map<String, Object?>> getBookingsSortedNewest() {
    final items = <Map<String, Object?>>[];
    for (final key in _bookingsBox.keys) {
      final v = _bookingsBox.get(key);
      if (v is Map) {
        items.add(v.map((k, val) => MapEntry(k.toString(), val)));
      }
    }
    items.sort((a, b) {
      final at = DateTime.tryParse((a['createdAt'] ?? '').toString());
      final bt = DateTime.tryParse((b['createdAt'] ?? '').toString());
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return items;
  }
}

