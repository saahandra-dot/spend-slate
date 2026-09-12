import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/repositories/category_repository.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());

    repository = CategoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('adds and reads custom category', () async {
    const category = AppCategory(
      id: 'custom-pets',
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.purple,
      isBuiltIn: false,
    );

    await repository.addCategory(category);

    final categories = await repository.getCategories();

    expect(categories.any((item) => item.id == 'custom-pets'), isTrue);
  });

  test('custom category preserves its values', () async {
    const category = AppCategory(
      id: 'custom-pets',
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.purple,
      isBuiltIn: false,
    );

    await repository.addCategory(category);

    final categories = await repository.getCategories();

    final savedCategory = categories.firstWhere(
      (item) => item.id == 'custom-pets',
    );

    expect(savedCategory.name, 'Pets');

    expect(savedCategory.type, TransactionType.expense);

    expect(savedCategory.iconKey, CategoryIconKey.other);

    expect(savedCategory.colorKey, CategoryColorKey.purple);

    expect(savedCategory.isBuiltIn, isFalse);
  });

  test('updates custom category', () async {
    const originalCategory = AppCategory(
      id: 'custom-pets',
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.purple,
      isBuiltIn: false,
    );

    await repository.addCategory(originalCategory);

    final updatedCategory = originalCategory.copyWith(
      name: 'Pet Care',
      colorKey: CategoryColorKey.orange,
    );

    await repository.updateCategory(
      updatedCategory,
      previousName: originalCategory.name,
    );

    final categories = await repository.getCategories();

    final savedCategory = categories.firstWhere(
      (item) => item.id == 'custom-pets',
    );

    expect(savedCategory.name, 'Pet Care');

    expect(savedCategory.colorKey, CategoryColorKey.orange);
  });

  test('deletes unused custom category', () async {
    const category = AppCategory(
      id: 'custom-pets',
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.purple,
      isBuiltIn: false,
    );

    await repository.addCategory(category);

    await repository.deleteCategory(category);

    final categories = await repository.getCategories();

    expect(categories.any((item) => item.id == 'custom-pets'), isFalse);
  });

  test('built-in category cannot be deleted', () async {
    const groceries = AppCategory(
      id: 'expense-groceries',
      name: 'Groceries',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.groceries,
      colorKey: CategoryColorKey.green,
      isBuiltIn: true,
    );

    expect(
      repository.deleteCategory(groceries),
      throwsA(isA<CategoryOperationException>()),
    );
  });

  test('category in use cannot be deleted', () async {
    const category = AppCategory(
      id: 'custom-pets',
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.purple,
      isBuiltIn: false,
    );

    await repository.addCategory(category);

    await database
        .into(database.transactionEntries)
        .insert(
          TransactionEntriesCompanion.insert(
            id: 'transaction-1',
            title: 'Pets',
            amount: 500,
            date: DateTime(2026, 9, 4),
            type: TransactionType.expense.name,
            category: 'Pets',
          ),
        );

    expect(
      repository.deleteCategory(category),
      throwsA(isA<CategoryOperationException>()),
    );
  });
}
