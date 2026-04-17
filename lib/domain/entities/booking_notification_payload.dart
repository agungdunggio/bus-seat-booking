class BookingNotificationPayload {
  const BookingNotificationPayload({
    required this.seatIds,
    required this.serviceName,
    required this.bookingDateIso,
  });

  final List<String> seatIds;
  final String serviceName;
  final String bookingDateIso;
}
