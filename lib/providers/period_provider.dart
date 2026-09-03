import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

class MonthlyComparison {
  final double current;
  final double previous;

  const MonthlyComparison({required this.current, required this.previous});

  double get difference {
    return current - previous;
  }

  double? get percentageChange {
    if (previous == 0) {
      if (current == 0) {
        return 0;
      }

      return null;
    }

    return ((current - previous) / previous) * 100;
  }

  bool get increased {
    return current > previous;
  }

  bool get decreased {
    return current < previous;
  }

  bool get unchanged {
    return current == previous;
  }
}

final previousMonthProvider = Provider<DateTime>((ref) {
  final DateTime selectedMonth = ref.watch(selectedMonthProvider);

  return DateTime(selectedMonth.year, selectedMonth.month - 1);
});

final previousMonthTransactionsProvider =
    Provider<AsyncValue<List<ExpenseTransaction>>>((ref) {
      final DateTime previousMonth = ref.watch(previousMonthProvider);

      final transactionsAsync = ref.watch(transactionsProvider);

      return transactionsAsync.whenData((transactions) {
        return transactions.where((transaction) {
          return transaction.date.year == previousMonth.year &&
              transaction.date.month == previousMonth.month;
        }).toList();
      });
    });

final previousMonthIncomeProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(previousMonthTransactionsProvider).value ??
      const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final previousMonthExpensesProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(previousMonthTransactionsProvider).value ??
      const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});
final monthlyIncomeComparisonProvider = Provider<MonthlyComparison>((ref) {
  final double current = ref.watch(monthlyIncomeProvider);

  final double previous = ref.watch(previousMonthIncomeProvider);

  return MonthlyComparison(current: current, previous: previous);
});
final monthlyExpenseComparisonProvider = Provider<MonthlyComparison>((ref) {
  final double current = ref.watch(monthlyExpensesProvider);

  final double previous = ref.watch(previousMonthExpensesProvider);

  return MonthlyComparison(current: current, previous: previous);
});

final selectedMonthProvider =
    NotifierProvider<SelectedMonthController, DateTime>(
      SelectedMonthController.new,
    );
final monthlyTransactionsProvider =
    Provider<AsyncValue<List<ExpenseTransaction>>>((ref) {
      final DateTime selectedMonth = ref.watch(selectedMonthProvider);

      final transactionsAsync = ref.watch(transactionsProvider);

      return transactionsAsync.whenData((transactions) {
        return transactions.where((transaction) {
          return transaction.date.year == selectedMonth.year &&
              transaction.date.month == selectedMonth.month;
        }).toList();
      });
    });

final monthlyIncomeProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(monthlyTransactionsProvider).value ??
      const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final monthlyExpensesProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(monthlyTransactionsProvider).value ??
      const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final monthlyNetProvider = Provider<double>((ref) {
  final double income = ref.watch(monthlyIncomeProvider);

  final double expenses = ref.watch(monthlyExpensesProvider);

  return income - expenses;
});

class SelectedMonthController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final DateTime now = DateTime.now();

    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void resetToCurrentMonth() {
    final DateTime now = DateTime.now();

    state = DateTime(now.year, now.month);
  }
}
