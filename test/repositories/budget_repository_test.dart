import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/repositories/budget_repository.dart';

void main() {
  late AppDatabase database;
  late BudgetRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());

    repository = BudgetRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('adds and reads a budget', () async {
    final budget = MonthlyBudget(
      id: 'budget-groceries-september',
      categoryId: 'expense-groceries',
      limitAmount: 5000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(budget);

    final budgets = await repository.getBudgets();

    expect(budgets.length, 1);

    expect(budgets.single.categoryId, 'expense-groceries');

    expect(budgets.single.limitAmount, 5000);

    expect(budgets.single.month, DateTime(2026, 9));
  });

  test('normalizes budget month', () async {
    final budget = MonthlyBudget(
      id: 'budget-cafe',
      categoryId: 'expense-cafe',
      limitAmount: 1000,
      month: DateTime(2026, 9, 28, 18, 30),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(budget);

    final saved = (await repository.getBudgets()).single;

    expect(saved.month, DateTime(2026, 9));
  });

  test('updates a budget', () async {
    final original = MonthlyBudget(
      id: 'budget-groceries',
      categoryId: 'expense-groceries',
      limitAmount: 5000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(original);

    final updated = original.copyWith(limitAmount: 6500);

    await repository.updateBudget(updated);

    final saved = (await repository.getBudgets()).single;

    expect(saved.limitAmount, 6500);
  });

  test('deletes a budget', () async {
    final budget = MonthlyBudget(
      id: 'budget-transport',
      categoryId: 'expense-transport',
      limitAmount: 2000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(budget);

    await repository.deleteBudget(budget.id);

    final budgets = await repository.getBudgets();

    expect(budgets, isEmpty);
  });

  test('rejects duplicate category budget for same month', () async {
    final first = MonthlyBudget(
      id: 'budget-groceries-1',
      categoryId: 'expense-groceries',
      limitAmount: 5000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    final second = MonthlyBudget(
      id: 'budget-groceries-2',
      categoryId: 'expense-groceries',
      limitAmount: 6000,
      month: DateTime(2026, 9, 20),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(first);

    expect(
      repository.addBudget(second),
      throwsA(isA<BudgetOperationException>()),
    );
  });

  test('same category can have budgets in different months', () async {
    final september = MonthlyBudget(
      id: 'budget-groceries-september',
      categoryId: 'expense-groceries',
      limitAmount: 5000,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    final october = MonthlyBudget(
      id: 'budget-groceries-october',
      categoryId: 'expense-groceries',
      limitAmount: 5500,
      month: DateTime(2026, 10),
      createdAt: DateTime(2026, 9, 8),
    );

    await repository.addBudget(september);

    await repository.addBudget(october);

    final budgets = await repository.getBudgets();

    expect(budgets.length, 2);
  });

  test('rejects zero budget limit', () async {
    final budget = MonthlyBudget(
      id: 'budget-invalid',
      categoryId: 'expense-groceries',
      limitAmount: 0,
      month: DateTime(2026, 9),
      createdAt: DateTime(2026, 9, 8),
    );

    expect(
      repository.addBudget(budget),
      throwsA(isA<BudgetOperationException>()),
    );
  });
}
