import 'package:bus_seat_booking/domain/entities/price_breakdown.dart';
import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';

Future<void> showPriceInfoBottomSheet(
  BuildContext context, {
  required DateTime bookingDate,
  required BusServiceType service,
  required int seatCount,
  required PriceBreakdown breakdown,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return _PriceInfoSheetBody(
        bookingDate: bookingDate,
        service: service,
        seatCount: seatCount,
        breakdown: breakdown,
      );
    },
  );
}

class _PriceInfoSheetBody extends StatelessWidget {
  const _PriceInfoSheetBody({
    required this.bookingDate,
    required this.service,
    required this.seatCount,
    required this.breakdown,
  });

  final DateTime bookingDate;
  final BusServiceType service;
  final int seatCount;
  final PriceBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rincian harga',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDateShort(bookingDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Layanan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${service.label} · ${formatRupiah(service.pricePerSeat)} / kursi',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Perhitungan pemesanan ini',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _BreakdownRow(
                label: '$seatCount × ${formatRupiah(service.pricePerSeat)}',
                value: formatRupiah(breakdown.subtotal),
              ),
              if (breakdown.hasWeekendFee) ...[
                const SizedBox(height: 8),
                _BreakdownRow(
                  label: 'Tambahan weekend (+20%)',
                  value: '+${formatRupiah(breakdown.weekendFee)}',
                  emphasize: true,
                ),
              ],
              if (breakdown.hasBulkDiscount) ...[
                const SizedBox(height: 8),
                _BreakdownRow(
                  label: 'Diskon 10% (≥ 5 kursi)',
                  value: '-${formatRupiah(breakdown.bulkDiscount)}',
                  emphasize: true,
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: cs.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formatRupiah(breakdown.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: service.getColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: service.getColor(context),
                ),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        
        Text(value, style: style),
      ],
    );
  }
}
