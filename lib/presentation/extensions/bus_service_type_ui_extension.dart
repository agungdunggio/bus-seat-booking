import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:flutter/material.dart';

extension BusServiceTypeUiExtension on BusServiceType {
  Color getColor(BuildContext context) {
    final theme = Theme.of(context);
    return switch (this) {
      BusServiceType.regular => theme.colorScheme.primary,
      BusServiceType.express => theme.colorScheme.tertiary,
    };
  }
}
