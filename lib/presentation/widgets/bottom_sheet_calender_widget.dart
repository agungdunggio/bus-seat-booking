import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/presentation/extensions/bus_service_type_ui_extension.dart';
import 'package:bus_seat_booking/presentation/widgets/legend_chip_calender_widget.dart';
import 'package:bus_seat_booking/presentation/widgets/seat_marker_calender_widget.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

typedef RemainingSeatsResolver = int Function(
  DateTime date,
  BusServiceType service,
);

class DateCalendarBottomSheet extends StatefulWidget {
  const DateCalendarBottomSheet({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.getRemainingSeats,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final RemainingSeatsResolver getRemainingSeats;

  @override
  State<DateCalendarBottomSheet> createState() =>
      DateCalendarBottomSheetState();
}

class DateCalendarBottomSheetState extends State<DateCalendarBottomSheet> {
  late DateTime _focusedDay = DateUtils.dateOnly(widget.initialDate);
  late DateTime _selectedDay = DateUtils.dateOnly(widget.initialDate);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regularColor = BusServiceType.regular.getColor(context);
    final expressColor = BusServiceType.express.getColor(context);
    final cs = theme.colorScheme; 

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pilih tanggal booking',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TableCalendar<void>(
            locale: idLocaleName,
            firstDay: widget.minDate,
            lastDay: widget.maxDate,
            focusedDay: _focusedDay,
            currentDay: DateUtils.dateOnly(DateTime.now()),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: 62,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ) ??
                  const TextStyle(),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ) ??
                  const TextStyle(),
              weekendStyle: theme.textTheme.labelSmall?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w700,
                  ) ??
                  const TextStyle(),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateUtils.dateOnly(selectedDay);
                _focusedDay = DateUtils.dateOnly(focusedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = DateUtils.dateOnly(focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, _) {
                final d = DateUtils.dateOnly(day);
                if (d.isBefore(widget.minDate) || d.isAfter(widget.maxDate)) {
                  return const SizedBox.shrink();
                }
                final regular =
                    widget.getRemainingSeats(d, BusServiceType.regular).toString();
                final express =
                    widget.getRemainingSeats(d, BusServiceType.express).toString();
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Wrap(
                    spacing: 3,
                    children: [
                      SeatMarkerCalenderWidget(
                        label: regular,
                        color: regularColor,
                      ),
                      SeatMarkerCalenderWidget(
                        label: express,
                        color: expressColor,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              LegendChipCalenderWidget(
                label: 'Regular',
                color: regularColor,
                totalSeats: BusServiceType.regular.totalSeats,
              ),
              LegendChipCalenderWidget(
                label: 'Express',
                color: expressColor,
                totalSeats: BusServiceType.express.totalSeats,
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_selectedDay),
            child: const Text('Pakai tanggal ini'),
          ),
        ],
      ),
    );
  }
}