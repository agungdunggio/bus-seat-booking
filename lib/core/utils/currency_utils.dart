String formatRupiah(
  int value, {
  bool withSymbol = true,
}) {
  final isNegative = value < 0;
  var n = value.abs();

  final digits = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }

  final formatted = buffer.toString();
  final symbol = withSymbol ? 'Rp ' : '';
  return '${isNegative ? '-' : ''}$symbol$formatted';
}

