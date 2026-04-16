bool isWeekendDate(DateTime date) {
  return date.weekday == DateTime.saturday ||
      date.weekday == DateTime.sunday;
}

bool isBulkDiscountEligible(int seatCount) => seatCount >= 5;

double applyWeekendPrice(double total, DateTime date) {
  return isWeekendDate(date) ? total * 1.2 : total;
}

double addWeekendPrice(double subtotal, DateTime date) {
  return isWeekendDate(date) ? subtotal * 0.2 : 0;
}

double applyDiscountPrice(double total, int seatCount) {
  return isBulkDiscountEligible(seatCount) ? total * 0.9 : total;
}

double removeDiscountPrice(double totalAfterWeekend, int seatCount) {
  return isBulkDiscountEligible(seatCount) ? totalAfterWeekend * 0.1 : 0;
}

double weekendAddedAmount(double subtotal, DateTime date) =>
    addWeekendPrice(subtotal, date);

double bulkDiscountAmount(double totalAfterWeekend, int seatCount) =>
    removeDiscountPrice(totalAfterWeekend, seatCount);

double weekendAdjustedTotal(double subtotal, DateTime date) =>
    applyWeekendPrice(subtotal, date);

double discountAdjustedTotal(
  double subtotal,
  DateTime date,
  int seatCount,
) {
  final afterWeekend = applyWeekendPrice(subtotal, date);
  return applyDiscountPrice(afterWeekend, seatCount);
}