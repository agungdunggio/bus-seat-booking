import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';

class BusServiceToggleWidget extends StatelessWidget {
  const BusServiceToggleWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BusServiceType value;
  final ValueChanged<BusServiceType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget label({
      required String title,
      required int price,
      required bool isSelected,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatRupiah(price),
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? cs.onPrimary.withValues(alpha: 0.9)
                  : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return SegmentedButton<BusServiceType>(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return value.getColor(context);
          return cs.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.onPrimary;
          return cs.onSurface;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? value.getColor(context)
              : cs.outlineVariant;
          return BorderSide(color: color);
        }),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
        overlayColor: WidgetStatePropertyAll(value.getColor(context).withValues(alpha: 0.08)),
      ),
      segments: [
        ButtonSegment(
          value: BusServiceType.regular,
          label: label(
            title: BusServiceType.regular.label,
            price: BusServiceType.regular.pricePerSeat,
            isSelected: value == BusServiceType.regular,
          ),
        ),
        ButtonSegment(
          value: BusServiceType.express,
          label: label(
            title: BusServiceType.express.label,
            price: BusServiceType.express.pricePerSeat,
            isSelected: value == BusServiceType.express,
          ),
        ),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}
