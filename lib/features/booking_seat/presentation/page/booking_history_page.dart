import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/local/booking_local_repository.dart';
import 'package:bus_seat_booking/core/local/local_boxes.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingsBox = Hive.box(LocalBoxes.bookings);
    final reservedBox = Hive.box(LocalBoxes.reservedSeats);
    final repo = BookingLocalRepository(
      bookingsBox: bookingsBox,
      reservedSeatsBox: reservedBox,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Booking')),
      body: ValueListenableBuilder(
        valueListenable: bookingsBox.listenable(),
        builder: (context, box, _) {
          final items = repo.getBookingsSortedNewest();
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada booking.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final b = items[index];
              final serviceName = (b['service'] ?? '').toString();
              final service = BusService.values
                  .where((e) => e.name == serviceName)
                  .cast<BusService?>()
                  .firstWhere((e) => e != null, orElse: () => null);
              final seats = (b['seats'] is List)
                  ? (b['seats'] as List).map((e) => e.toString()).toList()
                  : <String>[];
              final total = int.tryParse((b['totalPrice'] ?? '0').toString()) ?? 0;
              final createdAt = DateTime.tryParse((b['createdAt'] ?? '').toString());

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service?.label ?? serviceName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(formatRupiah(total)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        seats.isEmpty ? '-' : seats.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          createdAt.toLocal().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

