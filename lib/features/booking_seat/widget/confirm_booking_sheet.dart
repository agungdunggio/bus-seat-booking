import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';

Future<bool> showConfirmBookingSheet(
  BuildContext context, {
  required BusService service,
  required List<String> seatIds,
  required int totalPrice,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return _ConfirmBookingSheet(
        service: service,
        seatIds: seatIds,
        totalPrice: totalPrice,
      );
    },
  );

  return result == true;
}

class _ConfirmBookingSheet extends StatelessWidget {
  const _ConfirmBookingSheet({
    required this.service,
    required this.seatIds,
    required this.totalPrice,
  });

  final BusService service;
  final List<String> seatIds;
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seats = [...seatIds]..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Konfirmasi booking',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_bus, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        service.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatRupiah(service.pricePerSeat),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kursi dipilih',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in seats)
                        Container(
                          width: 40,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatRupiah(totalPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
                    foregroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
                    overlayColor: WidgetStateProperty.all(theme.colorScheme.primary.withAlpha(20)),
                    side: WidgetStateProperty.all(BorderSide(color: theme.colorScheme.primary)),
                    textStyle: WidgetStateProperty.all(theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Konfirmasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

