import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/data/category_catalog.dart';

part 'app_database.g.dart';

class TransactionEntries extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  TextColumn get account => text().nullable()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoryEntries extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get iconKey => text()();

  TextColumn get colorKey => text()();

  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class GoalEntries extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  RealColumn get targetAmount => real()();

  RealColumn get currentAmount => real().withDefault(const Constant(0))();

  DateTimeColumn get targetDate => dateTime().nullable()();

  TextColumn get iconKey => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class BudgetEntries extends Table {
  TextColumn get id => text()();

  TextColumn get categoryId => text()();

  RealColumn get limitAmount => real()();

  DateTimeColumn get month => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [TransactionEntries, CategoryEntries, GoalEntries, BudgetEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults() : super(driftDatabase(name: 'expense_tracker'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) async {
        await migrator.createAll();
      },

      onUpgrade: (Migrator migrator, int from, int to) async {
        if (from < 2) {
          await migrator.createTable(categoryEntries);
        }
        if (from < 3) {
          await migrator.createTable(goalEntries);
        }
        if (from < 4) {
          await migrator.createTable(budgetEntries);
        }
      },

      beforeOpen: (details) async {
        await _seedBuiltInCategories();
      },
    );
  }

  Future<void> _seedBuiltInCategories() async {
    for (final category in CategoryCatalog.categories) {
      await into(categoryEntries).insert(
        CategoryEntriesCompanion.insert(
          id: category.id,
          name: category.name,
          type: category.type.name,
          iconKey: category.iconKey.name,
          colorKey: category.colorKey.name,
          isBuiltIn: Value(category.isBuiltIn),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}
