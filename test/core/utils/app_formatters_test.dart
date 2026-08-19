import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/core/utils/app_formatters.dart';

void main() {
  group('AppFormatters currency', () {
    test('formats USD with thousands separators', () {
      expect(AppFormatters.currency(5000), '\$5,000.00');
    });

    test('formats large amounts', () {
      expect(AppFormatters.currency(1000000.50), '\$1,000,000.50');
    });

    test('formats negative currency', () {
      expect(AppFormatters.currency(-453.14), '-\$453.14');
    });
  });

  group('AppFormatters dates', () {
    test('formats a long date', () {
      expect(AppFormatters.date(DateTime(2026, 8, 16)), 'August 16, 2026');
    });

    test('formats month and year', () {
      expect(AppFormatters.monthYear(DateTime(2026, 8, 16)), 'August 2026');
    });
  });

  group('transaction group dates', () {
    final DateTime now = DateTime(2026, 8, 17);

    test('returns Today for current date', () {
      expect(
        AppFormatters.transactionGroupDate(DateTime(2026, 8, 17), now: now),
        'Today',
      );
    });

    test('returns Yesterday for previous date', () {
      expect(
        AppFormatters.transactionGroupDate(DateTime(2026, 8, 16), now: now),
        'Yesterday',
      );
    });

    test('formats older dates normally', () {
      expect(
        AppFormatters.transactionGroupDate(DateTime(2026, 8, 15), now: now),
        'August 15, 2026',
      );
    });
  });
}
