import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat currency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat date = DateFormat('dd/MM/yyyy');
}
