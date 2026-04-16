import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';
import 'package:bus_seat_booking/presentation/widgets/bottom_sheet_calender_widget.dart';
import 'package:flutter/material.dart';

class ButtonDateWidget extends StatelessWidget {
  const ButtonDateWidget({
    super.key,
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.getRemainingSeats,
    required this.onDateChanged,
    required this.service,
  });

  final DateTime selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final RemainingSeatsResolver getRemainingSeats;
  final ValueChanged<DateTime> onDateChanged;
  final BusServiceType service;
  
  DateTime get _date => DateUtils.dateOnly(selectedDate);
  DateTime get _minDate => DateUtils.dateOnly(minDate);
  DateTime get _maxDate => DateUtils.dateOnly(maxDate);

  void _goDay(int delta) {
    final next = _date.add(Duration(days: delta));
    if (next.isBefore(_minDate) || next.isAfter(_maxDate)) return;
    onDateChanged(next);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DateCalendarBottomSheet(
        initialDate: _date,
        minDate: _minDate,
        maxDate: _maxDate,
        getRemainingSeats: getRemainingSeats,
      ),
    );
    if (picked == null) return;
    onDateChanged(DateUtils.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = formatDateLong(_date);

    final canGoBack = _date.isAfter(_minDate);
    final canGoForward = _date.isBefore(_maxDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: canGoBack ? () => _goDay(-1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Hari sebelumnya',
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: service.getColor(context),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => canGoForward ? _goDay(1) : null,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Hari berikutnya',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
