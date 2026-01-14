import 'package:flutter/foundation.dart';

@immutable
class TripInfo {
  const TripInfo({
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    required this.pricePerSeat,
  });

  final String from;
  final String to;
  final DateTime date;
  final int passengers;
  final int pricePerSeat;
}

