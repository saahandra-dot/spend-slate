import 'package:flutter/material.dart';

import '../../models/app_currency.dart';
import '../utils/app_formatters.dart';

class AppCurrencyScope extends InheritedWidget {
  final AppCurrency currency;

  const AppCurrencyScope({
    super.key,
    required this.currency,
    required super.child,
  });

  static AppCurrency currencyOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppCurrencyScope>();

    return scope?.currency ?? AppCurrency.usd;
  }

  static String format(BuildContext context, double amount) {
    final AppCurrency currency = currencyOf(context);

    return AppFormatters.currency(
      amount,
      currencyCode: currency.code,
      locale: currency.locale,
    );
  }

  @override
  bool updateShouldNotify(AppCurrencyScope oldWidget) {
    return currency != oldWidget.currency;
  }
}
