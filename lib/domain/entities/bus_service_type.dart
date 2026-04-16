enum BusServiceType {
  regular,
  express,
}

extension BusServiceTypeX on BusServiceType {
  String get label => switch (this) {
        BusServiceType.regular => 'Regular',
        BusServiceType.express => 'Express',
      };

  int get pricePerSeat => switch (this) {
        BusServiceType.regular => 85000,
        BusServiceType.express => 150000,
      };

  int get rows => switch (this) {
        BusServiceType.regular => 5,
        BusServiceType.express => 3,
      };

  List<String> get seatLetters => switch (this) {
        BusServiceType.regular => const ['A', 'B', 'C', 'D'],
        BusServiceType.express => const ['A', 'B', 'C', 'D'],
      };

  int get totalSeats => rows * seatLetters.length;

  bool isValidSeatId(String seatId) {
    final match = RegExp(r'^(\d+)([A-D])$').firstMatch(seatId);
    if (match == null) return false;
    final row = int.tryParse(match.group(1) ?? '');
    final letter = match.group(2);
    if (row == null || letter == null) return false;
    if (row < 1 || row > rows) return false;
    return seatLetters.contains(letter);
  }
}
