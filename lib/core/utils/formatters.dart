import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2).format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
