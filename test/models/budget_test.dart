import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/models/budget.dart';

void main() {
  test('copyWith updates budget limit', () {
    final budget = MonthlyBudget(
      id: 'budget-1',
      categoryId: 'expense-groceries',
      limitAmount: 5000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    final updated = budget.copyWith(limitAmount: 7000);

    expect(updated.limitAmount, 7000);

    expect(updated.categoryId, budget.categoryId);

    expect(updated.month, budget.month);
  });
}
