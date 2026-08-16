import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final AppDatabase _database;

  TransactionRepository(this._database);

  Future<List<ExpenseTransaction>> getTransactions() async {
    final query = _database.select(_database.transactionEntries)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.date, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      return ExpenseTransaction(
        id: row.id,
        title: row.title,
        amount: row.amount,
        date: row.date,
        type: _transactionTypeFromString(row.type),
        category: row.category,
        account: row.account,
        note: row.note,
      );
    }).toList();
  }

  TransactionType _transactionTypeFromString(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;

      case 'expense':
        return TransactionType.expense;

      default:
        throw FormatException('Unknown transaction type: $value');
    }
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    await _database
        .into(_database.transactionEntries)
        .insert(
          TransactionEntriesCompanion.insert(
            id: transaction.id,
            title: transaction.title,
            amount: transaction.amount,
            date: transaction.date,
            type: transaction.type.name,
            category: transaction.category,
            account: Value(transaction.account),
            note: Value(transaction.note),
          ),
        );
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await (_database.update(
      _database.transactionEntries,
    )..where((table) => table.id.equals(transaction.id))).write(
      TransactionEntriesCompanion(
        title: Value(transaction.title),
        amount: Value(transaction.amount),
        date: Value(transaction.date),
        type: Value(transaction.type.name),
        category: Value(transaction.category),
        account: Value(transaction.account),
        note: Value(transaction.note),
      ),
    );
  }

  Future<void> deleteTransaction(String id) async {
    await (_database.delete(
      _database.transactionEntries,
    )..where((table) => table.id.equals(id))).go();
  }
}
