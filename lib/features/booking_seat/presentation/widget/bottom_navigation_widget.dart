import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';

class BottomNavigationWidget extends StatelessWidget {
  final String selectedSeats;
  final int totalPrice;
  final bool canContinue;
  final VoidCallback onConfirmBooking;

  const BottomNavigationWidget({
    super.key, 
    required this.selectedSeats, 
    required this.totalPrice, 
    required this.canContinue, 
    required this.onConfirmBooking
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seats = selectedSeats == '-' || selectedSeats.trim().isEmpty
        ? const <String>[]
        : selectedSeats.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Material(
      color: theme.colorScheme.surface,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 35),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SEAT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (seats.isEmpty)
                          Text('-', style: theme.textTheme.titleMedium)
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final s in seats)
                                SizedBox(
                                  width: 34,
                                  height: 24,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        s,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    width: 24,
                    thickness: 0.75,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PRICE',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(totalPrice),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: canContinue ? onConfirmBooking : null,
                child: Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}