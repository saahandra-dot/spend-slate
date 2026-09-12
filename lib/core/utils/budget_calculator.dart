import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

class BudgetCalculator {
  BudgetCalculator._();

  static BudgetUsage calculateUsage({
    required MonthlyBudget budget,
    required AppCategory? category,
    required List<ExpenseTransaction> transactions,
  }) {
    if (category == null) {
      return BudgetUsage(budget: budget, spentAmount: 0, transactionCount: 0);
    }

    final String categoryName = _normalize(category.name);

    final matchingTransactions = transactions.where((transaction) {
      return transaction.type == TransactionType.expense &&
          transaction.date.year == budget.month.year &&
          transaction.date.month == budget.month.month &&
          _normalize(transaction.category) == categoryName;
    }).toList();

    final double spent = matchingTransactions.fold(0.0, (total, transaction) {
      return total + transaction.amount;
    });

    return BudgetUsage(
      budget: budget,
      spentAmount: spent,
      transactionCount: matchingTransactions.length,
    );
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
