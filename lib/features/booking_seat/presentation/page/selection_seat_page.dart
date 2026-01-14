import 'package:bus_seat_booking/features/booking_seat/presentation/widget/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';

import '../../domain/trip_info.dart';
import '../widget/legend_dot_widget.dart';
import '../widget/seat_tile_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key, required this.trip});

  final TripInfo trip;

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const int _rows = 10;

  final Set<String> _selectedSeatIds = {};
  final List<String> _selectedSeatOrder = [];

  void _toggleSeat(String seatId) {
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  int get _totalPrice => _selectedSeatIds.length * widget.trip.pricePerSeat;

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
              Text('${widget.trip.from} → ${widget.trip.to}'),
              const SizedBox(height: 6),
              Text('Tanggal: ${_formatDate(widget.trip.date)}'),
              Text('Kursi: $selectedSeats'),
              const SizedBox(height: 6),
              Text('Total: Rp $_totalPrice'),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    LegendDotWidget(label: 'Tersedia', color: Colors.white),
                    LegendDotWidget(label: 'Dipilih', color: Colors.indigo),
                  ],
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // A B | C D
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: _rows * 5,
                        itemBuilder: (context, index) {
                          final row = (index ~/ 5) + 1;
                          final col = index % 5;

                          if (col == 2) {
                            return Center(
                              child: Text(
                                row.toString(), 
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800
                                )
                              )
                            );
                          }

                          final letter = switch (col) {
                            0 => 'A',
                            1 => 'B',
                            3 => 'C',
                            _ => 'D',
                          };

                          final seatId = '$row$letter';
                          final selected = _selectedSeatIds.contains(seatId);
                          final personNumber = selected
                              ? (_selectedSeatOrder.indexOf(seatId) + 1)
                              : null;

                          return SeatTileWidget(
                            seatId: seatId,
                            selected: selected,
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