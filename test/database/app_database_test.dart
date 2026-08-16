import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and reads a transaction', () async {
    await database
        .into(database.transactionEntries)
        .insert(
          TransactionEntriesCompanion.insert(
            id: 'test-1',
            title: 'Groceries',
            amount: 850.50,
            date: DateTime(2026, 8, 14),
            type: 'expense',
            category: 'Groceries',
            account: const Value('Debit Card'),
            note: const Value('Weekly shopping'),
          ),
        );

    final transactions = await database
        .select(database.transactionEntries)
        .get();

    expect(transactions.length, 1);

    expect(transactions.first.title, 'Groceries');

    expect(transactions.first.amount, 850.50);

    expect(transactions.first.type, 'expense');
  });
}
