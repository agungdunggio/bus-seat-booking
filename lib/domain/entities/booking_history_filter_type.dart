enum BookingHistoryFilterType {
  all,
  today,
  last7Days,
  last30Days,
  custom,
}

extension BookingHistoryFilterTypeX on BookingHistoryFilterType {
  String get label {
    return switch (this) {
      BookingHistoryFilterType.all => 'Semua',
      BookingHistoryFilterType.today => 'Hari ini',
      BookingHistoryFilterType.last7Days => '7 hari',
      BookingHistoryFilterType.last30Days => '30 hari',
      BookingHistoryFilterType.custom => 'Rentang Waktu',
    };
  }
}