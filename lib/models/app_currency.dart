enum AppCurrency {
  usd(code: 'USD', label: 'US Dollar', locale: 'en_US'),
  mxn(code: 'MXN', label: 'Mexican Peso', locale: 'es_MX'),
  eur(code: 'EUR', label: 'Euro', locale: 'de_DE'),
  gbp(code: 'GBP', label: 'British Pound', locale: 'en_GB');

  final String code;
  final String label;
  final String locale;

  const AppCurrency({
    required this.code,
    required this.label,
    required this.locale,
  });

  static AppCurrency fromCode(String? code) {
    for (final currency in values) {
      if (currency.code == code) {
        return currency;
      }
    }

    return AppCurrency.usd;
  }
}
