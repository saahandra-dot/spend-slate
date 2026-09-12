import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/budget.dart';

class BudgetOperationException implements Exception {
  final String message;

  const BudgetOperationException(this.message);

  @override
  String toString() => message;
}

class BudgetRepository {
  final AppDatabase _database;

  BudgetRepository(this._database);

  Future<List<MonthlyBudget>> getBudgets() async {
    final query = _database.select(_database.budgetEntries)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.month, mode: OrderingMode.desc),
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      return MonthlyBudget(
        id: row.id,
        categoryId: row.categoryId,
        limitAmount: row.limitAmount,
        month: _normalizeMonth(row.month),
        createdAt: row.createdAt,
      );
    }).toList();
  }

  Future<void> addBudget(MonthlyBudget budget) async {
    _validateBudget(budget);

    final bool duplicate = await hasBudgetForCategoryAndMonth(
      categoryId: budget.categoryId,
      month: budget.month,
    );

    if (duplicate) {
      throw const BudgetOperationException(
        'A budget already exists for this category and month.',
      );
    }

    await _database
        .into(_database.budgetEntries)
        .insert(
          BudgetEntriesCompanion.insert(
            id: budget.id,
            categoryId: budget.categoryId,
            limitAmount: budget.limitAmount,
            month: _normalizeMonth(budget.month),
            createdAt: budget.createdAt,
          ),
        );
  }

  Future<void> updateBudget(MonthlyBudget budget) async {
    _validateBudget(budget);

    final bool duplicate = await hasBudgetForCategoryAndMonth(
      categoryId: budget.categoryId,
      month: budget.month,
      excludingId: budget.id,
    );

    if (duplicate) {
      throw const BudgetOperationException(
        'A budget already exists for this category and month.',
      );
    }

    await (_database.update(
      _database.budgetEntries,
    )..where((table) => table.id.equals(budget.id))).write(
      BudgetEntriesCompanion(
        categoryId: Value(budget.categoryId),
        limitAmount: Value(budget.limitAmount),
        month: Value(_normalizeMonth(budget.month)),
        createdAt: Value(budget.createdAt),
      ),
    );
  }

  Future<void> deleteBudget(String id) async {
    await (_database.delete(
      _database.budgetEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<bool> hasBudgetForCategoryAndMonth({
    required String categoryId,
    required DateTime month,
    String? excludingId,
  }) async {
    final DateTime normalizedMonth = _normalizeMonth(month);

    final query = _database.select(_database.budgetEntries)
      ..where(
        (table) =>
            table.categoryId.equals(categoryId) &
            table.month.equals(normalizedMonth),
      );

    final rows = await query.get();

    return rows.any((row) => row.id != excludingId);
  }

  void _validateBudget(MonthlyBudget budget) {
    if (budget.categoryId.trim().isEmpty) {
      throw const BudgetOperationException('Choose a category.');
    }

    if (!budget.limitAmount.isFinite || budget.limitAmount <= 0) {
      throw const BudgetOperationException(
        'Budget limit must be greater than 0.',
      );
    }
  }

  DateTime _normalizeMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }
}
