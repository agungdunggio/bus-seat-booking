import 'package:bus_seat_booking/core/utils/price_utils.dart';
import 'package:bus_seat_booking/domain/entities/bus_service_type.dart';
import 'package:bus_seat_booking/domain/entities/price_breakdown.dart';

class CalculateBookingTotalUseCase {
  PriceBreakdown call({
    required DateTime date,
    required BusServiceType service,
    required int seatCount,
  }) {
    if (seatCount == 0) {
      return PriceBreakdown(subtotal: 0, weekendFee: 0, bulkDiscount: 0, totalPrice: 0);
    }

    final subtotal = seatCount * service.pricePerSeat;
    final weekendFee = weekendAddedAmount(subtotal.toDouble(), date).toInt();
    final afterWeekend = subtotal + weekendFee;
    final discount = bulkDiscountAmount(afterWeekend.toDouble(), seatCount).toInt();
    
    return PriceBreakdown(
      subtotal: subtotal,
      weekendFee: weekendFee,
      bulkDiscount: discount,
      totalPrice: afterWeekend - discount,
    );
  }
}