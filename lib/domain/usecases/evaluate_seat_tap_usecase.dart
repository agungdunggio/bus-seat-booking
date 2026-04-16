enum SeatTapAction { add, remove, blocked }

class SeatTapResult {
  const SeatTapResult._({
    required this.action,
    this.seatId,
  });

  const SeatTapResult.add(String seatId)
      : this._(action: SeatTapAction.add, seatId: seatId);

  const SeatTapResult.remove(String seatId)
      : this._(action: SeatTapAction.remove, seatId: seatId);

  const SeatTapResult.blocked()
      : this._(action: SeatTapAction.blocked, seatId: null);

  final SeatTapAction action;
  final String? seatId;
}

class EvaluateSeatTapUseCase {
  SeatTapResult call({
    required String seatId,
    required Set<String> selectedSeatIds,
    required Set<String> reservedSeatIds,
  }) {
    if (selectedSeatIds.contains(seatId)) {
      return SeatTapResult.remove(seatId);
    }
    if (reservedSeatIds.contains(seatId)) {
      return const SeatTapResult.blocked();
    }
    return SeatTapResult.add(seatId);
  }
}
