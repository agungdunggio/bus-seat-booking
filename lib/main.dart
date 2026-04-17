import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bus_seat_booking/core/bindings/global_binding.dart';
import 'package:bus_seat_booking/core/navigation/app_pages.dart';
import 'package:bus_seat_booking/core/navigation/app_routes.dart';
import 'package:bus_seat_booking/data/local/local_boxes.dart';
import 'package:bus_seat_booking/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox(LocalBoxes.reservedSeats);
  await Hive.openBox(LocalBoxes.bookings);
  await initializeDateFormatting('id', 'ID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Seat Booking',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      initialBinding: GlobalBinding(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: AppRoutes.seatSelection,
      getPages: AppPages.pages,
    );
  }
}
