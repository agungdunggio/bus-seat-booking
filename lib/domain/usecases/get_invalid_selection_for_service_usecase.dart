import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';

class GetInvalidSelectionForServiceUseCase {
  List<String> call({
    required BusServiceType service,
    required Set<String> selectedSeatIds,
  }) {
    return selectedSeatIds
        .where((s) => !service.isValidSeatId(s))
        .toList(growable: false);
  }
}
