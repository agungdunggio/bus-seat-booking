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

  Set<String> get unavailableSeatIds => switch (this) {
        BusService.regular => const {'1A', '2C', '3D', '5B'},
        BusService.express => const {'1A', '2C', '3D'},
      };
}

