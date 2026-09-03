import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/providers/period_provider.dart';

void main() {
  test('selected month is normalized to first day of month', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    container
        .read(selectedMonthProvider.notifier)
        .setMonth(DateTime(2026, 8, 20, 15, 30));

    expect(container.read(selectedMonthProvider), DateTime(2026, 8));
  });

  test('selected month can move backward and forward', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final controller = container.read(selectedMonthProvider.notifier);

    controller.setMonth(DateTime(2026, 1));

    controller.previousMonth();

    expect(container.read(selectedMonthProvider), DateTime(2025, 12));

    controller.nextMonth();

    expect(container.read(selectedMonthProvider), DateTime(2026, 1));
  });

  test('previous month follows selected month', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    container.read(selectedMonthProvider.notifier).setMonth(DateTime(2026, 8));

    expect(container.read(previousMonthProvider), DateTime(2026, 7));
  });

  test('previous month handles year boundary', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    container.read(selectedMonthProvider.notifier).setMonth(DateTime(2026, 1));

    expect(container.read(previousMonthProvider), DateTime(2025, 12));
  });

  test('monthly comparison calculates percentage change', () {
    const comparison = MonthlyComparison(current: 4250, previous: 3800);

    expect(comparison.difference, 450);

    expect(comparison.percentageChange, closeTo(11.8421, 0.001));

    expect(comparison.increased, isTrue);
  });

  test('comparison avoids division by zero', () {
    const comparison = MonthlyComparison(current: 5000, previous: 0);

    expect(comparison.difference, 5000);

    expect(comparison.percentageChange, isNull);
  });
}
