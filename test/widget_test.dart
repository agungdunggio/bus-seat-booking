// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bus_seat_booking/data/local/local_boxes.dart';
import 'package:bus_seat_booking/main.dart';

void main() {
  late Directory hiveTestDir;

  setUpAll(() async {
    hiveTestDir = await Directory.systemTemp.createTemp('bus_seat_booking_hive_');
    Hive.init(hiveTestDir.path);
    await Hive.openBox(LocalBoxes.reservedSeats);
    await Hive.openBox(LocalBoxes.bookings);
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveTestDir.existsSync()) {
      await hiveTestDir.delete(recursive: true);
    }
  });

  testWidgets('Aplikasi terbuka dan tampil halaman pilih kursi', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bus Seat Booking'), findsOneWidget);
  });
}
