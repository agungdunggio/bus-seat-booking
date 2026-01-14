import 'package:bus_seat_booking/features/booking_seat/widget/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bus_seat_booking/core/constants/bus_service.dart';
import 'package:bus_seat_booking/core/local/booking_local_repository.dart';
import 'package:bus_seat_booking/core/local/local_boxes.dart';
import 'package:bus_seat_booking/core/utils/currency_utils.dart';
import 'package:bus_seat_booking/features/booking_seat/widget/bus_service_toggle_widget.dart';
import 'package:bus_seat_booking/features/booking_seat/page/booking_history_page.dart';
import 'package:bus_seat_booking/features/booking_seat/widget/bottom_toast_widget.dart';
import 'package:bus_seat_booking/features/booking_seat/widget/legend_dot_widget.dart';
import 'package:bus_seat_booking/features/booking_seat/widget/seat_tile_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  BusService _service = BusService.regular;

  final Set<String> _selectedSeatIds = {};
  final List<String> _selectedSeatOrder = [];

  late final Box _reservedSeatsBox;
  late final Box _bookingsBox;
  late final BookingLocalRepository _repo;

  @override
  void initState() {
    super.initState();
    _reservedSeatsBox = Hive.box(LocalBoxes.reservedSeats);
    _bookingsBox = Hive.box(LocalBoxes.bookings);
    _repo = BookingLocalRepository(
      bookingsBox: _bookingsBox,
      reservedSeatsBox: _reservedSeatsBox,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _repo.sanitizeOrResetReservedSeats(BusService.regular);
      await _repo.sanitizeOrResetReservedSeats(BusService.express);
    });
  }

  void _sanitizeSelectionIfNeeded() {
    final invalid = _selectedSeatIds
        .where((s) => !_service.isValidSeatId(s))
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
    if (_repo.getReservedSeats(_service).contains(seatId)) return;
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
    final reservedNow = _repo.getReservedSeats(_service);
    final conflict = _selectedSeatOrder.where(reservedNow.contains).toList();
    if (conflict.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kursi ini sudah tidak tersedia: ${conflict.join(', ')}',
          ),
        ),
      );
      setState(() {
        for (final s in conflict) {
          _selectedSeatIds.remove(s);
          _selectedSeatOrder.remove(s);
        }
      });
      return;
    }

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

    await _repo.addBooking(
      service: _service,
      seatIds: List<String>.from(_selectedSeatOrder),
      totalPrice: _totalPrice,
    );
    final didReset = await _repo.reserveSeatsOrResetIfFull(
      service: _service,
      seatIds: List<String>.from(_selectedSeatOrder),
    );

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

    if (!mounted) return;
    if (didReset) {
      BottomToast.show(context, message: '${_service.label} sudah penuh, kursi di-reset untuk trip berikutnya.');
    }
  }

  @override
  Widget build(BuildContext context) {
    _sanitizeSelectionIfNeeded();

    final theme = Theme.of(context);
    final canContinue = _selectedSeatIds.isNotEmpty;
    final selectedSeats = _selectedSeatIds.isEmpty
        ? '-'
        : _selectedSeatOrder.join(', ');

    return ValueListenableBuilder(
      valueListenable: _reservedSeatsBox.listenable(),
      builder: (context, _, __) {
        final reservedSeatsLive = _repo.getReservedSeats(_service);
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Bus Seat Booking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                  );
                },
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
                      _repo.sanitizeOrResetReservedSeats(v);
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
                          final unavailable = reservedSeatsLive.contains(seatId);
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
      },
    );
  }
}