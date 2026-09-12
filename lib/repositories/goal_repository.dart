import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/goal.dart';

class GoalRepository {
  final AppDatabase _database;

  GoalRepository(this._database);

  Future<List<SavingsGoal>> getGoals() async {
    final query = _database.select(_database.goalEntries)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      return SavingsGoal(
        id: row.id,
        name: row.name,
        targetAmount: row.targetAmount,
        currentAmount: row.currentAmount,
        targetDate: row.targetDate,
        iconKey: _goalIconFromString(row.iconKey),
        createdAt: row.createdAt,
        isCompleted: row.isCompleted,
      );
    }).toList();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await _database
        .into(_database.goalEntries)
        .insert(
          GoalEntriesCompanion.insert(
            id: goal.id,
            name: goal.name,
            targetAmount: goal.targetAmount,
            currentAmount: Value(goal.currentAmount),
            targetDate: Value(goal.targetDate),
            iconKey: goal.iconKey.name,
            createdAt: goal.createdAt,
            isCompleted: Value(goal.isCompleted),
          ),
        );
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await (_database.update(
      _database.goalEntries,
    )..where((table) => table.id.equals(goal.id))).write(
      GoalEntriesCompanion(
        name: Value(goal.name),
        targetAmount: Value(goal.targetAmount),
        currentAmount: Value(goal.currentAmount),
        targetDate: Value(goal.targetDate),
        iconKey: Value(goal.iconKey.name),
        createdAt: Value(goal.createdAt),
        isCompleted: Value(goal.isCompleted),
      ),
    );
  }

  Future<void> deleteGoal(String id) async {
    await (_database.delete(
      _database.goalEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  GoalIconKey _goalIconFromString(String value) {
    try {
      return GoalIconKey.values.byName(value);
    } on ArgumentError {
      return GoalIconKey.other;
    }
  }
}
