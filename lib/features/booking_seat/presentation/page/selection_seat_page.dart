import 'package:bus_seat_booking/features/booking_seat/presentation/widget/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';

import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/features/booking_seat/presentation/widget/bus_service_toggle_widget.dart';
import '../widget/legend_dot_widget.dart';
import '../widget/seat_tile_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  BusService _service = BusService.regular;

  final Set<String> _selectedSeatIds = {};
  final List<String> _selectedSeatOrder = [];

  bool _isValidSeatIdForCurrentService(String seatId) {
    final match = RegExp(r'^(\d+)([A-D])$').firstMatch(seatId);
    if (match == null) return false;
    final row = int.tryParse(match.group(1) ?? '');
    final letter = match.group(2);
    if (row == null || letter == null) return false;
    if (row < 1 || row > _service.rows) return false;
    return _service.seatLetters.contains(letter);
  }

  void _sanitizeSelectionIfNeeded() {
    final invalid = _selectedSeatIds
        .where((s) => !_isValidSeatIdForCurrentService(s))
        .toList(growable: false);
    if (invalid.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        for (final s in invalid) {
          _selectedSeatIds.remove(s);
          _selectedSeatOrder.remove(s);
        }
      });
    });
  }

  void _toggleSeat(String seatId) {
    if (_service.unavailableSeatIds.contains(seatId)) return;
    setState(() {
      if (_selectedSeatIds.contains(seatId)) {
        _selectedSeatIds.remove(seatId);
        _selectedSeatOrder.remove(seatId);
        return;
      }
      _selectedSeatIds.add(seatId);
      _selectedSeatOrder.add(seatId);
    });
  }

  int get _totalPrice => _selectedSeatIds.length * _service.pricePerSeat;

  Future<void> _confirmBooking() async {
    if (_selectedSeatIds.isEmpty) return;

    final selectedSeats = _selectedSeatOrder.join(', ');

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text('Kursi: $selectedSeats'),
              const SizedBox(height: 6),
              Text('Total: ${formatRupiah(_totalPrice)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Booking berhasil dibuat.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _selectedSeatIds.clear();
      _selectedSeatOrder.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    _sanitizeSelectionIfNeeded();

    final theme = Theme.of(context);
    final canContinue = _selectedSeatIds.isNotEmpty;
    final selectedSeats = _selectedSeatIds.isEmpty
        ? '-'
        : _selectedSeatOrder.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Seat Booking',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w600
            ),
          ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
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
                    value: _service,
                    onChanged: (v) {
                      setState(() {
                        _service = v;
                        _selectedSeatIds.clear();
                        _selectedSeatOrder.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LegendDotWidget(label: 'Tersedia', color: Colors.white),
                      LegendDotWidget(label: 'Dipilih', color: theme.colorScheme.primary),
                      LegendDotWidget(label: 'Tidak tersedia', color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                          ],
                          stops: [0.0, 0.10],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 36, bottom: 18),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _service.gridColumns,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: _service.seatTileAspectRatio,
                        ),
                        itemCount: _service.rows * _service.gridColumns,
                        itemBuilder: (context, index) {
                          final row = (index ~/ _service.gridColumns) + 1;
                          final col = index % _service.gridColumns;

                          if (col == _service.aisleColumnIndex) {
                            return const SizedBox.shrink();
                          }

                          final letter = _service.seatLetterForGridColumn(col);
                          if (letter == null) return const SizedBox.shrink();

                          final seatId = '$row$letter';
                          final selected = _selectedSeatIds.contains(seatId);
                          final unavailable = _service.unavailableSeatIds.contains(seatId);
                          final personNumber = selected
                              ? (_selectedSeatOrder.indexOf(seatId) + 1)
                              : null;

                          return SeatTileWidget(
                            seatId: seatId,
                            selected: selected,
                            unavailable: unavailable,
                            personNumber: personNumber,
                            onTap: () => _toggleSeat(seatId),
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
        selectedSeats: selectedSeats,
        totalPrice: _totalPrice,
        canContinue: canContinue,
        onConfirmBooking: _confirmBooking,
      ),
    );
  }
}