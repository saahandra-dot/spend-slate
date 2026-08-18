import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();

  ref.onDispose(database.close);

  return database;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return TransactionRepository(database);
});

final transactionsProvider =
    AsyncNotifierProvider<TransactionController, List<ExpenseTransaction>>(
      TransactionController.new,
    );

final totalIncomeProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(transactionsProvider).value ?? const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final totalExpensesProvider = Provider<double>((ref) {
  final transactions =
      ref.watch(transactionsProvider).value ?? const <ExpenseTransaction>[];

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (total, transaction) => total + transaction.amount);
});

final currentBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);

  final expenses = ref.watch(totalExpensesProvider);

  return income - expenses;
});

class TransactionController extends AsyncNotifier<List<ExpenseTransaction>> {
  TransactionRepository get _repository =>
      ref.read(transactionRepositoryProvider);

  @override
  Future<List<ExpenseTransaction>> build() {
    final repository = ref.watch(transactionRepositoryProvider);

    return repository.getTransactions();
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    await _repository.addTransaction(transaction);

    await _reloadTransactions();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await _repository.updateTransaction(transaction);

    await _reloadTransactions();
  }

  Future<void> removeTransaction(String id) async {
    await _repository.deleteTransaction(id);

    await _reloadTransactions();
  }

  Future<void> _reloadTransactions() async {
    final transactions = await _repository.getTransactions();

    state = AsyncData(transactions);
  }
}
