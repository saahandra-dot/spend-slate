import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/models/goal.dart';

void main() {
  SavingsGoal createGoal({
    double targetAmount = 10000,
    double currentAmount = 2500,
    DateTime? targetDate,
    bool isCompleted = false,
  }) {
    return SavingsGoal(
      id: 'goal-test',
      name: 'Vacation',
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      iconKey: GoalIconKey.vacation,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: isCompleted,
    );
  }

  test('calculates Goal progress', () {
    final goal = createGoal();

    expect(goal.progress, 0.25);

    expect(goal.progressPercentage, 25);
  });

  test('calculates remaining amount', () {
    final goal = createGoal();

    expect(goal.remainingAmount, 7500);
  });

  test('progress cannot exceed 100 percent', () {
    final goal = createGoal(
      targetAmount: 10000,
      currentAmount: 12500,
      isCompleted: true,
    );

    expect(goal.progress, 1);

    expect(goal.progressPercentage, 100);

    expect(goal.remainingAmount, 0);
  });

  test('detects reached target', () {
    final goal = createGoal(targetAmount: 5000, currentAmount: 5000);

    expect(goal.hasReachedTarget, isTrue);
  });

  test('calculates days until target', () {
    final goal = createGoal(targetDate: DateTime(2026, 9, 20));

    final days = goal.daysUntilTarget(now: DateTime(2026, 9, 10));

    expect(days, 10);
  });

  test('detects overdue Goal', () {
    final goal = createGoal(targetDate: DateTime(2026, 9, 1));

    expect(goal.isOverdue(now: DateTime(2026, 9, 10)), isTrue);
  });

  test('completed Goal is not overdue', () {
    final goal = createGoal(
      targetAmount: 10000,
      currentAmount: 10000,
      targetDate: DateTime(2026, 9, 1),
      isCompleted: true,
    );

    expect(goal.isOverdue(now: DateTime(2026, 9, 10)), isFalse);
  });
}
