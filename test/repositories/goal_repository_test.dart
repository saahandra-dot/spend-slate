import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/models/goal.dart';
import 'package:expense_tracker/repositories/goal_repository.dart';

void main() {
  late AppDatabase database;
  late GoalRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());

    repository = GoalRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('adds and reads a goal', () async {
    final goal = SavingsGoal(
      id: 'goal-vacation',
      name: 'Vacation',
      targetAmount: 10000,
      currentAmount: 2500,
      targetDate: DateTime(2026, 12, 20),
      iconKey: GoalIconKey.vacation,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: false,
    );

    await repository.addGoal(goal);

    final goals = await repository.getGoals();

    expect(goals.length, 1);

    expect(goals.first.name, 'Vacation');

    expect(goals.first.targetAmount, 10000);

    expect(goals.first.currentAmount, 2500);

    expect(goals.first.iconKey, GoalIconKey.vacation);

    expect(goals.first.isCompleted, isFalse);
  });

  test('updates a goal', () async {
    final original = SavingsGoal(
      id: 'goal-laptop',
      name: 'Laptop',
      targetAmount: 3000,
      currentAmount: 500,
      targetDate: null,
      iconKey: GoalIconKey.laptop,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: false,
    );

    await repository.addGoal(original);

    final updated = original.copyWith(
      name: 'New MacBook',
      targetAmount: 3500,
      currentAmount: 1000,
    );

    await repository.updateGoal(updated);

    final goals = await repository.getGoals();

    expect(goals.single.name, 'New MacBook');

    expect(goals.single.targetAmount, 3500);

    expect(goals.single.currentAmount, 1000);
  });

  test('deletes a goal', () async {
    final goal = SavingsGoal(
      id: 'goal-emergency',
      name: 'Emergency Fund',
      targetAmount: 20000,
      currentAmount: 5000,
      targetDate: null,
      iconKey: GoalIconKey.emergency,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: false,
    );

    await repository.addGoal(goal);

    await repository.deleteGoal(goal.id);

    final goals = await repository.getGoals();

    expect(goals, isEmpty);
  });

  test('preserves completed state', () async {
    final goal = SavingsGoal(
      id: 'goal-gift',
      name: 'Birthday Gift',
      targetAmount: 500,
      currentAmount: 500,
      targetDate: DateTime(2026, 10, 1),
      iconKey: GoalIconKey.gift,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: true,
    );

    await repository.addGoal(goal);

    final savedGoal = (await repository.getGoals()).single;

    expect(savedGoal.isCompleted, isTrue);
  });

  test('goal target date can be null', () async {
    final goal = SavingsGoal(
      id: 'goal-emergency-no-date',
      name: 'Emergency Fund',
      targetAmount: 10000,
      currentAmount: 1000,
      targetDate: null,
      iconKey: GoalIconKey.emergency,
      createdAt: DateTime(2026, 9, 7),
      isCompleted: false,
    );

    await repository.addGoal(goal);

    final saved = (await repository.getGoals()).single;

    expect(saved.targetDate, isNull);
  });
}
