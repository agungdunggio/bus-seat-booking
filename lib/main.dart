import 'package:flutter/material.dart';

import 'features/booking_seat/domain/trip_info.dart';
import 'features/booking_seat/presentation/page/selection_seat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Seat Booking',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: SeatSelectionScreen(
        trip: TripInfo(
          from: 'Jakarta',
          to: 'Bandung',
          date: DateTime.now(),
          passengers: 1,
          pricePerSeat: 85000,
        ),
      ),
    );
  }
}
