import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/core/data/category_catalog.dart';
import 'package:expense_tracker/models/transaction.dart';

void main() {
  test('expense category list contains Groceries', () {
    final categories = CategoryCatalog.forType(TransactionType.expense);

    expect(categories.map((category) => category.name), contains('Groceries'));
  });

  test('income category list contains Salary', () {
    final categories = CategoryCatalog.forType(TransactionType.income);

    expect(categories.map((category) => category.name), contains('Salary'));
  });

  test('category lookup ignores capitalization', () {
    final category = CategoryCatalog.find('gRoCeRiEs', TransactionType.expense);

    expect(category, isNotNull);

    expect(category!.id, 'expense-groceries');
  });

  test('all built-in category ids are unique', () {
    final ids = CategoryCatalog.categories
        .map((category) => category.id)
        .toList();

    expect(ids.toSet().length, ids.length);
  });
}
