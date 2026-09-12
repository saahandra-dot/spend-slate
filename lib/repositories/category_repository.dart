import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class CategoryOperationException implements Exception {
  final String message;

  const CategoryOperationException(this.message);

  @override
  String toString() => message;
}

class CategoryRepository {
  final AppDatabase _database;

  CategoryRepository(this._database);

  Future<List<AppCategory>> getCategories() async {
    final rows = await _database.select(_database.categoryEntries).get();

    final categories = rows.map((row) {
      return AppCategory(
        id: row.id,
        name: row.name,
        type: TransactionType.values.byName(row.type),
        iconKey: CategoryIconKey.values.byName(row.iconKey),
        colorKey: CategoryColorKey.values.byName(row.colorKey),
        isBuiltIn: row.isBuiltIn,
      );
    }).toList();

    categories.sort((first, second) {
      if (first.type != second.type) {
        return first.type.index.compareTo(second.type.index);
      }

      if (first.isBuiltIn != second.isBuiltIn) {
        return first.isBuiltIn ? -1 : 1;
      }

      return first.name.compareTo(second.name);
    });

    return categories;
  }

  Future<void> addCategory(AppCategory category) async {
    await _database
        .into(_database.categoryEntries)
        .insert(
          CategoryEntriesCompanion.insert(
            id: category.id,
            name: category.name,
            type: category.type.name,
            iconKey: category.iconKey.name,
            colorKey: category.colorKey.name,
            isBuiltIn: Value(category.isBuiltIn),
          ),
        );
  }

  Future<void> updateCategory(
    AppCategory category, {
    required String previousName,
  }) async {
    if (category.isBuiltIn) {
      throw const CategoryOperationException(
        'Built-in categories cannot be edited.',
      );
    }

    await _database.transaction(() async {
      await (_database.update(
        _database.categoryEntries,
      )..where((table) => table.id.equals(category.id))).write(
        CategoryEntriesCompanion(
          name: Value(category.name),
          iconKey: Value(category.iconKey.name),
          colorKey: Value(category.colorKey.name),
        ),
      );

      if (previousName != category.name) {
        await (_database.update(_database.transactionEntries)..where(
              (table) =>
                  table.category.equals(previousName) &
                  table.type.equals(category.type.name),
            ))
            .write(TransactionEntriesCompanion(category: Value(category.name)));
      }
    });
  }

  Future<bool> isCategoryInUse(AppCategory category) async {
    final transactionQuery = _database.select(_database.transactionEntries)
      ..where(
        (table) =>
            table.category.equals(category.name) &
            table.type.equals(category.type.name),
      )
      ..limit(1);

    final bool usedByTransaction =
        await transactionQuery.getSingleOrNull() != null;

    if (usedByTransaction) {
      return true;
    }

    final budgetQuery = _database.select(_database.budgetEntries)
      ..where((table) => table.categoryId.equals(category.id))
      ..limit(1);

    return await budgetQuery.getSingleOrNull() != null;
  }

  Future<void> deleteCategory(AppCategory category) async {
    if (category.isBuiltIn) {
      throw const CategoryOperationException(
        'Built-in categories cannot be deleted.',
      );
    }

    if (await isCategoryInUse(category)) {
      throw const CategoryOperationException(
        'This category is currently in use and cannot be deleted.',
      );
    }

    await (_database.delete(
      _database.categoryEntries,
    )..where((table) => table.id.equals(category.id))).go();
  }
}
