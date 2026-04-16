class PriceBreakdown {
  final int subtotal;
  final int weekendFee;
  final int bulkDiscount;
  final int totalPrice;

  PriceBreakdown({
    required this.subtotal,
    required this.weekendFee,
    required this.bulkDiscount,
    required this.totalPrice,
  });

  bool get hasWeekendFee => weekendFee > 0;
  bool get hasBulkDiscount => bulkDiscount > 0;

  int get priceDelta => totalPrice - subtotal;
}