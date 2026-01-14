import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/local/booking_local_repository.dart';
import 'package:bus_seat_booking/core/local/local_boxes.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';

Future<void> showBookingHistorySheet(BuildContext context) async {
  final bookingsBox = Hive.box(LocalBoxes.bookings);
  final reservedBox = Hive.box(LocalBoxes.reservedSeats);
  final repo = BookingLocalRepository(
    bookingsBox: bookingsBox,
    reservedSeatsBox: reservedBox,
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return _BookingHistorySheet(repo: repo);
    },
  );
}

class _BookingHistorySheet extends StatelessWidget {
  const _BookingHistorySheet({required this.repo});

  final BookingLocalRepository repo;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ValueListenableBuilder(
      valueListenable: Hive.box(LocalBoxes.bookings).listenable(),
      builder: (context, _, _) {
        final items = repo.getBookingsSortedNewest();
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Belum ada booking.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final grouped = <DateTime, List<Map<String, Object?>>>{};
        int totalRevenue = 0;

        for (final item in items) {
          final createdAt = DateTime.tryParse((item['createdAt'] ?? '').toString());
          if (createdAt == null) continue;

          final local = createdAt.toLocal();
          final dateOnly = DateTime(local.year, local.month, local.day);
          grouped.putIfAbsent(dateOnly, () => []).add(item);
          final price = int.tryParse((item['totalPrice'] ?? '0').toString()) ?? 0;
          totalRevenue += price;
        }

        final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = MediaQuery.of(context).size.height * 0.85;
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sales History',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      shrinkWrap: true,
                      itemCount: sortedDates.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, dateIndex) {
                  final dateKey = sortedDates[dateIndex];
                  final bookings = grouped[dateKey] ?? [];
                  final dateLabel = formatDate(dateKey);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          dateLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...bookings.map((b) {
                        final seats = (b['seats'] is List)
                            ? (b['seats'] as List).map((e) => e.toString()).toList()
                            : <String>[];
                        final total = int.tryParse((b['totalPrice'] ?? '0').toString()) ?? 0;
                        final serviceName = (b['service'] ?? '').toString();
                        final service = BusService.values
                            .where((e) => e.name == serviceName)
                            .cast<BusService?>()
                            .firstWhere((e) => e != null, orElse: () => null);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            color: cs.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.primaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          service?.label ?? serviceName,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: cs.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatRupiah(total),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.event_seat,
                                        size: 16,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          seats.isEmpty ? '-' : seats.join(', '),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      border: Border(
                        top: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total Revenue Generated',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatRupiah(totalRevenue),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
