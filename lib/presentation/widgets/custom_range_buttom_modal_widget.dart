import 'package:bus_seat_booking/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class CustomRangeBottomModalWidget extends StatefulWidget {
  const CustomRangeBottomModalWidget({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onApply,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime start, DateTime end) onApply;

  static Future<void> show(
    BuildContext context, {
    required DateTime? initialStart,
    required DateTime? initialEnd,
    required void Function(DateTime start, DateTime end) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CustomRangeBottomModalWidget(
        initialStart: initialStart,
        initialEnd: initialEnd,
        onApply: onApply,
      ),
    );
  }

  @override
  State<CustomRangeBottomModalWidget> createState() =>
      _CustomRangeBottomModalWidgetState();
}

class _CustomRangeBottomModalWidgetState
    extends State<CustomRangeBottomModalWidget> {
  late DateTime? _draftStart = widget.initialStart;
  late DateTime? _draftEnd = widget.initialEnd;

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: (_draftStart != null && _draftEnd != null && !_draftStart!.isAfter(_draftEnd!))
          ? DateTimeRange(start: _draftStart!, end: _draftEnd!)
          : null,
      currentDate: now,
    );
    if (picked == null) return;
    setState(() {
      _draftStart = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      _draftEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter Range Booking',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11),
                      ),
                      onTap: () => _pickRange(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _draftStart == null
                                    ? 'Tanggal mulai'
                                    : formatDate(_draftStart!),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: cs.outline,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: cs.outline,
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(11),
                      ),
                      onTap: () => _pickRange(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _draftEnd == null
                                  ? 'Tanggal akhir'
                                  : formatDate(_draftEnd!),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _draftStart != null && _draftEnd != null
                ? () {
                    widget.onApply(_draftStart!, _draftEnd!);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}