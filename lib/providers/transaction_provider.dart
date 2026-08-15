import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';

final transactionsProvider =
    NotifierProvider<TransactionController, List<ExpenseTransaction>>(
      TransactionController.new,
    );
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);

  return transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final totalExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final currentBalanceProvider = Provider<double>((ref) {
  final totalIncome = ref.watch(totalIncomeProvider);

  final totalExpenses = ref.watch(totalExpensesProvider);

  return totalIncome - totalExpenses;
});

class TransactionController extends Notifier<List<ExpenseTransaction>> {
  @override
  List<ExpenseTransaction> build() {
    return [
      ExpenseTransaction(
        id: '1',
        title: 'Cash, EUR',
        amount: 354.25,
        date: DateTime(2026, 1, 12),
        type: TransactionType.expense,
        category: 'Cash',
        account: 'Red Card',
      ),
      ExpenseTransaction(
        id: '2',
        title: 'Cafes',
        amount: 12.49,
        date: DateTime(2026, 1, 12),
        type: TransactionType.expense,
        category: 'Cafe',
        account: 'Vacation',
      ),
      ExpenseTransaction(
        id: '3',
        title: 'Groceries',
        amount: 86.40,
        date: DateTime(2026, 1, 12),
        type: TransactionType.expense,
        category: 'Groceries',
        account: 'Debit Card',
      ),
    ];
  }

  void addTransaction(ExpenseTransaction transaction) {
    state = [transaction, ...state];
  }

  void updateTransaction(ExpenseTransaction updatedTransaction) {
    state = [
      for (final transaction in state)
        if (transaction.id == updatedTransaction.id)
          updatedTransaction
        else
          transaction,
    ];
  }

  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }
}
