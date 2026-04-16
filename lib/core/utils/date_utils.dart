import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Locale idLocale = Locale('id', 'ID');

String get idLocaleName => idLocale.languageCode;

String formatDate(DateTime d) {
  return DateFormat('d MMMM y', idLocaleName).format(d);
}

String formatDateLong(DateTime d) {
  return DateFormat('EEEE, d MMMM y', idLocaleName).format(d);
}

String formatDateShort(DateTime d) {
  return DateFormat('EEEE, d MMM y', idLocaleName).format(d);
}

String bookingDateToStorageKey(DateTime d) {
  final x = DateTime(d.year, d.month, d.day);
  final m = x.month.toString().padLeft(2, '0');
  final day = x.day.toString().padLeft(2, '0');
  return '${x.year}-$m-$day';
}

DateTime bookingDateFromStorageKey(String key) {
  final p = key.split('-');
  if (p.length != 3) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime(
    int.tryParse(p[0]) ?? 0,
    int.tryParse(p[1]) ?? 1,
    int.tryParse(p[2]) ?? 1,
  );
}

bool isBookingDateStorageKey(String key) {
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key);
}

