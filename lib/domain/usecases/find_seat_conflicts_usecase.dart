class FindSeatConflictsUseCase {
  List<String> call({
    required List<String> selectedSeatOrder,
    required Set<String> reservedSeatIds,
  }) {
    return selectedSeatOrder.where(reservedSeatIds.contains).toList();
  }
}
