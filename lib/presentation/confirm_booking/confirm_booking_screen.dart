import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';
import 'package:bus_seat_booking/presentation/widgets/section_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/text_form_field_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/presentation/confirm_booking/controller/confirm_booking_controller.dart';

class ConfirmBookingScreen extends GetView<ConfirmBookingController> {
  const ConfirmBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Konfirmasi Booking',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        surfaceTintColor: cs.surface,
        backgroundColor: cs.surface,
      ),
      body: Obx(() {
        if (!controller.hasValidArgs.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final args = controller.args;
        final seats = [...args.seatIds]..sort();
        final tripLabel = formatDateLong(args.bookingDate);

        return SafeArea(
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionWidget(
                          title: 'Detail perjalanan',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: args.service.getColor(context),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tripLabel,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_bus_rounded,
                                    color: args.service.getColor(context),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      args.service.label,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SectionWidget(
                          title: 'Data penumpang',
                          subtitle: 'Pastikan sesuai KTP/identitas.',
                          child: Column(
                            children: [
                              TextFormFieldCustomWidget(
                                focusedBorderColor: args.service.getColor(context),
                                controller: controller.nameController,
                                enabled: !controller.isLoading,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                labelText: 'Nama penumpang',
                                hintText: 'Contoh: Budi Santoso',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Nama wajib diisi';
                                  }
                                  if (v.length < 3) {
                                    return 'Nama minimal 3 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormFieldCustomWidget(
                                focusedBorderColor: args.service.getColor(context),
                                labelText: 'Alamat',
                                hintText: 'Contoh: Jl. Merdeka No. 10, Bandung',
                                controller: controller.addressController,
                                enabled: !controller.isLoading,
                                maxLines: 2,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.done,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Alamat wajib diisi';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  if (!controller.isLoading) {
                                    controller.confirmBooking();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SectionWidget(
                          title: 'Ringkasan',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final s in seats)
                                    Chip(
                                      label: Text(
                                        s,
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: args.service.getColor(context),
                                        ),
                                      ),
                                      backgroundColor: args.service.getColor(context).withAlpha(20),
                                      side: BorderSide(color: args.service.getColor(context).withAlpha(60)),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total pembayaran',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(args.totalPrice),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: args.service.getColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: args.service.getColor(context),
                      ),
                      onPressed:
                          controller.isLoading ? null : controller.confirmBooking,
                      child: controller.isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Memproses...'),
                              ],
                            )
                          : const Text('Konfirmasi & Booking'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}