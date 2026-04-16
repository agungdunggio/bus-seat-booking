import 'package:bus_seat_booking/domain/entities/booking_history_filter_type.dart';
import 'package:bus_seat_booking/presentation/widgets/booking_card_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/custom_range_buttom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/presentation/booking_history/controller/booking_history_controller.dart';

class BookingHistoryScreen extends GetView<BookingHistoryController> {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final content = Obx(() {
      final groups = controller.dayGroups;
      final totalRevenue = controller.totalRevenue.value;
      final activeFilter = controller.selectedFilter.value;

      return Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final filter in BookingHistoryFilterType.values) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selectedColor: cs.secondary,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      label: Text(
                        style: TextStyle(
                          color: activeFilter == filter ? cs.onSecondary : cs.onSurfaceVariant,
                        ),
                        filter == BookingHistoryFilterType.custom
                            ? controller.customRangeLabel
                            : filter.label,
                      ),
                      selected: activeFilter == filter,
                      onSelected: (_) {
                        if (filter == BookingHistoryFilterType.custom) {
                          CustomRangeBottomModalWidget.show(
                            context,
                            initialStart: controller.customStartDate.value,
                            initialEnd: controller.customEndDate.value,
                            onApply: controller.setCustomRange,
                          );
                          return;
                        }
                        controller.setFilter(filter);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (groups.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Belum ada booking pada filter ini.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, dateIndex) {
                  final group = groups[dateIndex];
                  final dateLabel = formatDate(group.date);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          dateLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...group.bookings.map((b) => BookingCardWidget(booking: b)),
                    ],
                  );
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            decoration: BoxDecoration(
              color: cs.surface,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.surface.withValues(alpha: 0.9),
                  cs.surface,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, -4),
                  blurRadius: 14,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Total Pendapatan',
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
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan', 
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surface,
      ),
      body: SafeArea(child: content),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}