import 'package:bus_seat_booking/presentation/widgets/button_date_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';
import 'package:bus_seat_booking/presentation/seat_selection/controller/seat_selection_controller.dart';
import 'package:bus_seat_booking/presentation/seat_selection/utils/bus_seat_layout.dart';
import 'package:bus_seat_booking/presentation/widgets/bottom_navigation_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/modal_bottom_info_discount_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/bus_service_toggle_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/legend_dot_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/seat_tile_widget.dart';

class SelectionSeatPage extends GetView<SeatSelectionController> {
  const SelectionSeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final service = controller.selectedService.value;
      final layout = BusSeatLayout(service);
      controller.hiveReservedTick.value;
      final reservedSeatsLive = controller.reservedForCurrentService;

      final canContinue = controller.selectedSeatOrder.isNotEmpty;

      final breakdown = controller.priceBreakdown.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bus Seat Booking',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: controller.navigateToBookingHistory,
              icon: const Icon(Icons.history_rounded),
            ),
          ],
          surfaceTintColor: theme.colorScheme.surface,
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: BusServiceToggleWidget(
                      value: service,
                      onChanged: controller.onBusServiceChanged,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        LegendDotWidget(
                          label: 'Tersedia',
                          color: Colors.white,
                        ),
                        LegendDotWidget(
                          label: 'Dipilih',
                          color: service.getColor(context),
                        ),
                        LegendDotWidget(
                          label: 'Tidak tersedia',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ButtonDateWidget(
              selectedDate: controller.selectedBookingDate.value,
              minDate: controller.minBookingDate,
              maxDate: controller.maxBookingDate,
              getRemainingSeats: controller.remainingSeatsFor,
              onDateChanged: controller.onBookingDateChanged,
              service: service,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                            stops: [0.0, 0.10],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: GridView.builder(
                          padding: const EdgeInsets.only(top: 36, bottom: 18),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: layout.gridColumns,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: layout.seatTileAspectRatio,
                          ),
                          itemCount: service.rows * layout.gridColumns,
                          itemBuilder: (context, index) {
                            final row = (index ~/ layout.gridColumns) + 1;
                            final col = index % layout.gridColumns;

                            if (col == layout.aisleColumnIndex) {
                              return const SizedBox.shrink();
                            }

                            final letter = layout.seatLetterForGridColumn(col);
                            if (letter == null) return const SizedBox.shrink();

                            final seatId = '$row$letter';
                            final selected = controller.selectedSeatOrder.contains(seatId);
                            final unavailable = reservedSeatsLive.contains(seatId);
                            final personNumber = selected
                                ? (controller.selectedSeatOrder.indexOf(seatId) +
                                    1)
                                : null;

                            return SeatTileWidget(
                              seatId: seatId,
                              service: service,
                              selected: selected,
                              unavailable: unavailable,
                              personNumber: personNumber,
                              onTap: () => controller.onSeatTap(seatId),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationWidget(
          service: service,
          selectedSeats: controller.selectedSeatOrder,
          breakdown: breakdown,
          onPriceInfo: () {
            if (breakdown == null) return;
            showPriceInfoBottomSheet(
              context,
              bookingDate: controller.selectedBookingDate.value,
              service: service,
              seatCount: controller.selectedSeatOrder.length,
              breakdown: breakdown,
            );
          },
          canContinue: canContinue,
          onConfirmBooking: controller.navigateToConfirmBooking,
        ),
      );
    });
  }
}
