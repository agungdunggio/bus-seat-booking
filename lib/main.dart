import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/booking_seat/page/selection_seat_page.dart';
import 'core/local/local_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(LocalBoxes.reservedSeats);
  await Hive.openBox(LocalBoxes.bookings);
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
      home: SeatSelectionScreen(),
    );
  }
}
