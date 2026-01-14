import 'package:flutter/material.dart';

class SeatTileWidget extends StatelessWidget {

  final String seatId;
  final bool selected;
  final bool unavailable;
  final int? personNumber;
  final VoidCallback onTap;

  const SeatTileWidget({
    super.key,
    required this.seatId,
    required this.selected,
    this.unavailable = false,
    this.personNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = unavailable
        ? Colors.grey.shade400
        : (selected ? theme.colorScheme.primary : theme.colorScheme.surface);

    final fg = (unavailable || selected) ? Colors.white : theme.colorScheme.onSurface;

    final title = selected ? 'Person ${personNumber ?? 1}' : seatId;
    final icon = selected ? Icons.person : Icons.event_seat;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: unavailable ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: unavailable
                  ? Colors.transparent
                  : (selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}