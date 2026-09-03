import '../../models/category.dart';
import '../../models/transaction.dart';

class CategoryCatalog {
  CategoryCatalog._();

  static const List<AppCategory> categories = [
    // EXPENSE CATEGORIES
    AppCategory(
      id: 'expense-groceries',
      name: 'Groceries',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.groceries,
      colorKey: CategoryColorKey.green,
    ),

    AppCategory(
      id: 'expense-cafe',
      name: 'Cafe',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.cafe,
      colorKey: CategoryColorKey.orange,
    ),

    AppCategory(
      id: 'expense-clothing',
      name: 'Clothing',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.clothing,
      colorKey: CategoryColorKey.purple,
    ),

    AppCategory(
      id: 'expense-transport',
      name: 'Transport',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.transport,
      colorKey: CategoryColorKey.blue,
    ),

    AppCategory(
      id: 'expense-entertainment',
      name: 'Entertainment',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.entertainment,
      colorKey: CategoryColorKey.purple,
    ),

    AppCategory(
      id: 'expense-health',
      name: 'Health',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.health,
      colorKey: CategoryColorKey.red,
    ),

    AppCategory(
      id: 'expense-education',
      name: 'Education',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.education,
      colorKey: CategoryColorKey.blue,
    ),

    AppCategory(
      id: 'expense-bills',
      name: 'Bills',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.bills,
      colorKey: CategoryColorKey.orange,
    ),

    AppCategory(
      id: 'expense-other',
      name: 'Other',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.other,
      colorKey: CategoryColorKey.secondary,
    ),

    // INCOME CATEGORIES
    AppCategory(
      id: 'income-salary',
      name: 'Salary',
      type: TransactionType.income,
      iconKey: CategoryIconKey.salary,
      colorKey: CategoryColorKey.positive,
    ),

    AppCategory(
      id: 'income-freelance',
      name: 'Freelance',
      type: TransactionType.income,
      iconKey: CategoryIconKey.freelance,
      colorKey: CategoryColorKey.blue,
    ),

    AppCategory(
      id: 'income-business',
      name: 'Business',
      type: TransactionType.income,
      iconKey: CategoryIconKey.business,
      colorKey: CategoryColorKey.purple,
    ),

    AppCategory(
      id: 'income-investment',
      name: 'Investment',
      type: TransactionType.income,
      iconKey: CategoryIconKey.investment,
      colorKey: CategoryColorKey.positive,
    ),

    AppCategory(
      id: 'income-gift',
      name: 'Gift',
      type: TransactionType.income,
      iconKey: CategoryIconKey.gift,
      colorKey: CategoryColorKey.orange,
    ),

    AppCategory(
      id: 'income-other',
      name: 'Other Income',
      type: TransactionType.income,
      iconKey: CategoryIconKey.money,
      colorKey: CategoryColorKey.positive,
    ),
  ];

  static List<AppCategory> forType(TransactionType type) {
    return categories.where((category) => category.type == type).toList();
  }

  static AppCategory? find(String name, TransactionType type) {
    final String normalizedName = name.trim().toLowerCase();

    for (final category in categories) {
      if (category.type == type &&
          category.name.toLowerCase() == normalizedName) {
        return category;
      }
    }

    return null;
  }
}
