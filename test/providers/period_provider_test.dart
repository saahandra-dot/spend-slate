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
}
