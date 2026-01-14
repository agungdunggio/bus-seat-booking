enum BusService {
  regular,
  express,
}

extension BusServiceX on BusService {
  String get label => switch (this) {
        BusService.regular => 'Regular',
        BusService.express => 'Express',
      };

  int get pricePerSeat => switch (this) {
        BusService.regular => 85000,
        BusService.express => 150000,
      };

  int get rows => switch (this) {
        BusService.regular => 5, 
        BusService.express => 3, 
      };

  int get gridColumns => switch (this) {
        BusService.regular => 5, 
        BusService.express => 5, 
      };

  int get aisleColumnIndex => switch (this) {
        BusService.regular => 2,
        BusService.express => 2,
      };

 
  double get seatTileAspectRatio => switch (this) {
        BusService.regular => 1.0,
        BusService.express => 0.5,
      };

  List<String> get seatLetters => switch (this) {
        BusService.regular => const ['A', 'B', 'C', 'D'],
        BusService.express => const ['A', 'B', 'C', 'D'],
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

  String? seatLetterForGridColumn(int col) {
    if (col == aisleColumnIndex) return null;
    return switch (this) {
      BusService.regular || BusService.express => switch (col) {
          0 => 'A',
          1 => 'B',
          3 => 'C',
          _ => 'D',
        },
    };
  }
}

