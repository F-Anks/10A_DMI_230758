import 'package:intl/intl.dart';

class HumanFormats {
  static String number(double number, [int decimals = 0]) {
    return NumberFormat.compactCurrency(
      decimalDigits: decimals,
      symbol: '',
      locale: 'en',
    ).format(number);
  }

  static String shortDate(DateTime date, [String languageCode = 'es']) {
    final format = DateFormat.yMMMEd(languageCode);
    return format.format(date);
  }

  /// Devuelve el día actual localizado (por ejemplo "Lunes 16" o "Monday 16").
  static String today([String languageCode = 'es']) {
    final formatted = DateFormat('EEEE d', languageCode).format(DateTime.now());
    if (formatted.isEmpty) return formatted;
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
