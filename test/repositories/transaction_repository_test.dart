import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/repositories/transaction_repository.dart';

void main() {
  late AppDatabase database;
  late TransactionRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());

    repository = TransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('adds and reads a transaction', () async {
    final transaction = ExpenseTransaction(
      id: '1',
      title: 'Groceries',
      amount: 850.50,
      date: DateTime(2026, 8, 15),
      type: TransactionType.expense,
      category: 'Groceries',
      account: 'Debit Card',
      note: 'Weekly groceries',
    );

    await repository.addTransaction(transaction);

    final transactions = await repository.getTransactions();

    expect(transactions.length, 1);

    expect(transactions.first.id, '1');

    expect(transactions.first.title, 'Groceries');

    expect(transactions.first.amount, 850.50);

    expect(transactions.first.type, TransactionType.expense);

    expect(transactions.first.account, 'Debit Card');
  });

  test('updates a transaction', () async {
    final original = ExpenseTransaction(
      id: '1',
      title: 'Groceries',
      amount: 500,
      date: DateTime(2026, 8, 15),
      type: TransactionType.expense,
      category: 'Groceries',
      account: 'Debit Card',
    );

    await repository.addTransaction(original);

    final updated = ExpenseTransaction(
      id: '1',
      title: 'Groceries',
      amount: 750,
      date: DateTime(2026, 8, 15),
      type: TransactionType.expense,
      category: 'Groceries',
      account: 'Credit Card',
      note: 'Updated transaction',
    );

    await repository.updateTransaction(updated);

    final transactions = await repository.getTransactions();

    expect(transactions.length, 1);

    expect(transactions.first.amount, 750);

    expect(transactions.first.account, 'Credit Card');

    expect(transactions.first.note, 'Updated transaction');
  });

  test('deletes a transaction', () async {
    final transaction = ExpenseTransaction(
      id: 'delete-me',
      title: 'Cafe',
      amount: 20,
      date: DateTime(2026, 8, 15),
      type: TransactionType.expense,
      category: 'Cafe',
      account: 'Cash',
    );

    await repository.addTransaction(transaction);

    var transactions = await repository.getTransactions();

    expect(transactions.length, 1);

    await repository.deleteTransaction('delete-me');

    transactions = await repository.getTransactions();

    expect(transactions, isEmpty);
  });

  test('preserves income transaction type', () async {
    final transaction = ExpenseTransaction(
      id: 'income-1',
      title: 'Salary',
      amount: 5000,
      date: DateTime(2026, 8, 15),
      type: TransactionType.income,
      category: 'Salary',
      account: 'Savings',
    );

    await repository.addTransaction(transaction);

    final transactions = await repository.getTransactions();

    expect(transactions.first.type, TransactionType.income);
  });

  test('returns newest transactions first', () async {
    await repository.addTransaction(
      ExpenseTransaction(
        id: 'older',
        title: 'Older',
        amount: 10,
        date: DateTime(2026, 8, 10),
        type: TransactionType.expense,
        category: 'Other',
      ),
    );

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'newer',
        title: 'Newer',
        amount: 20,
        date: DateTime(2026, 8, 15),
        type: TransactionType.expense,
        category: 'Other',
      ),
    );

    final transactions = await repository.getTransactions();

    expect(transactions.first.id, 'newer');

    expect(transactions.last.id, 'older');
  });
}
