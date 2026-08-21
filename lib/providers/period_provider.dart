import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

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
