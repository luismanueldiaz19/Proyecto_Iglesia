class CurrencyFormatter {
  /// Formatea un monto double agregando comas como separador de miles
  /// y manteniendo 2 lugares decimales.
  /// Ejemplo: 2250.36 -> "2,250.36"
  static String formatAmount(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final dec = parts[1];
    String result = '';
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        result += ',';
      }
      result += whole[i];
    }
    return '${isNegative ? '-' : ''}$result.$dec';
  }
}
