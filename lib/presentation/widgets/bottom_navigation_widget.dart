import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/entities/price_breakdown.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';
import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/presentation/widgets/delta_icon_animated_widget.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({
    super.key,
    required this.selectedSeats,
    required this.breakdown,
    required this.onPriceInfo,
    required this.canContinue,
    required this.onConfirmBooking,
    required this.service,
  });

  final List<String> selectedSeats;
  final PriceBreakdown? breakdown;
  final VoidCallback onPriceInfo;
  final bool canContinue;
  final VoidCallback onConfirmBooking;
  final BusServiceType service;

  Widget _buildDeltaIcon(BuildContext context, bool hasSeats, int delta) {
    if (!hasSeats || delta == 0) {
      return const SizedBox(width: 0, height: 24);
    }
    return DeltaIconAnimatedWidget(isIncrease: delta > 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seats = selectedSeats;
    final total = breakdown?.totalPrice ?? 0;
    final delta = breakdown?.priceDelta ?? 0;
    final hasWeekend = breakdown?.hasWeekendFee ?? false;
    final hasBulk = breakdown?.hasBulkDiscount ?? false;

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
                          'KURSI',
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
                                      color: service.getColor(context),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'HARGA',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _buildDeltaIcon(
                                context,
                                seats.isNotEmpty,
                                delta,
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Text(
                                  formatRupiah(total),
                                  maxLines: 1,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (seats.isNotEmpty && (hasWeekend || hasBulk)) ...[
                              IconButton(
                                onPressed: onPriceInfo,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Info harga',
                                icon: Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
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
                style: FilledButton.styleFrom(
                  backgroundColor: service.getColor(context),
                ),
                onPressed: canContinue ? onConfirmBooking : null,
                child: const Text('Konfirmasi Pemesanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
