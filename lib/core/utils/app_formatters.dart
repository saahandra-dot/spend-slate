import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static const String defaultLocale = 'en_US';

  static const String defaultCurrencyCode = 'USD';

  static String currency(
    double amount, {
    String currencyCode = defaultCurrencyCode,
    String locale = defaultLocale,
  }) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  static String date(DateTime date, {String locale = defaultLocale}) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  static String fullDate(DateTime date, {String locale = defaultLocale}) {
    return DateFormat.yMMMMEEEEd(locale).format(date);
  }

  static String shortDate(DateTime date, {String locale = defaultLocale}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  static String monthYear(DateTime date, {String locale = defaultLocale}) {
    return DateFormat.yMMMM(locale).format(date);
  }
}
