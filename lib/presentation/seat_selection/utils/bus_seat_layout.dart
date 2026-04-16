import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

class BusSeatLayout {
  const BusSeatLayout(this.service);

  final BusServiceType service;

  int get gridColumns => switch (service) {
        BusServiceType.regular => 5,
        BusServiceType.express => 5,
      };

  int get aisleColumnIndex => switch (service) {
        BusServiceType.regular => 2,
        BusServiceType.express => 2,
      };

  double get seatTileAspectRatio => switch (service) {
        BusServiceType.regular => 1.0,
        BusServiceType.express => 0.5,
      };

  String? seatLetterForGridColumn(int col) {
    if (col == aisleColumnIndex) return null;
    return switch (service) {
      BusServiceType.regular || BusServiceType.express => switch (col) {
          0 => 'A',
          1 => 'B',
          3 => 'C',
          _ => 'D',
        },
    };
  }
}
