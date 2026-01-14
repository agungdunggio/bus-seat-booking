import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';

class BusServiceToggleWidget extends StatelessWidget {
  const BusServiceToggleWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BusService value;
  final ValueChanged<BusService> onChanged;

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

    return SegmentedButton<BusService>(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.onPrimary;
          return cs.onSurface;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? cs.primary
              : cs.outlineVariant;
          return BorderSide(color: color);
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        overlayColor: WidgetStatePropertyAll(cs.primary.withValues(alpha: 0.08)),
      ),
      segments: [
        ButtonSegment(
          value: BusService.regular,
          label: label(
            title: 'Regular',
            price: BusService.regular.pricePerSeat,
            isSelected: value == BusService.regular,
          ),
        ),
        ButtonSegment(
          value: BusService.express,
          label: label(
            title: 'Express',
            price: BusService.express.pricePerSeat,
            isSelected: value == BusService.express,
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
