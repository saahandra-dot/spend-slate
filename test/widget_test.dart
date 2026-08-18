import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/repositories/transaction_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets(
    'Expense Tracker shows empty state when there are no transactions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const ExpenseTrackerApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);

      expect(find.text('Current Balance'), findsOneWidget);

      expect(find.text('No transactions yet'), findsOneWidget);

      expect(find.text('Transactions'), findsOneWidget);
    },
  );

  testWidgets('empty state Add Transaction button opens form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const ExpenseTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);

    final addButton = find.widgetWithText(ElevatedButton, 'Add Transaction');

    expect(addButton, findsOneWidget);

    await tester.ensureVisible(addButton);

    await tester.pumpAndSettle();

    await tester.tap(addButton);

    await tester.pumpAndSettle();

    expect(find.text('Amount'), findsOneWidget);

    expect(find.text('Category'), findsOneWidget);

    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('View All opens full transaction history', (
    WidgetTester tester,
  ) async {
    final repository = TransactionRepository(database);

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'test-transaction',
        title: 'Groceries',
        amount: 100,
        date: DateTime(2026, 8, 17),
        type: TransactionType.expense,
        category: 'Groceries',
        account: 'Debit Card',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const ExpenseTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    final viewAllButton = find.text('View All');

    expect(viewAllButton, findsOneWidget);

    await tester.ensureVisible(viewAllButton);

    await tester.pumpAndSettle();

    await tester.tap(viewAllButton);

    await tester.pumpAndSettle();

    expect(find.text('All Transactions'), findsOneWidget);

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('1 transaction'), findsOneWidget);
  });
}
