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

  testWidgets('search filters transactions', (WidgetTester tester) async {
    final repository = TransactionRepository(database);

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'groceries',
        title: 'Groceries',
        amount: 100,
        date: DateTime(2026, 8, 17),
        type: TransactionType.expense,
        category: 'Groceries',
        account: 'Debit Card',
      ),
    );

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'cafe',
        title: 'Cafe',
        amount: 25,
        date: DateTime(2026, 8, 17),
        type: TransactionType.expense,
        category: 'Cafe',
        account: 'Cash',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const ExpenseTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    final viewAll = find.text('View All');

    await tester.ensureVisible(viewAll);

    await tester.pumpAndSettle();

    await tester.tap(viewAll);

    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('Cafe'), findsOneWidget);

    final searchField = find.byKey(const Key('transactionSearchField'));

    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'groc');

    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('Cafe'), findsNothing);

    await tester.enterText(searchField, 'something impossible');

    await tester.pumpAndSettle();

    expect(find.text('No matching transactions'), findsOneWidget);

    expect(find.text('Groceries'), findsNothing);

    expect(find.text('Cafe'), findsNothing);
  });

  testWidgets('expense filter hides income transactions', (
    WidgetTester tester,
  ) async {
    final repository = TransactionRepository(database);

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'salary',
        title: 'Salary',
        amount: 5000,
        date: DateTime(2026, 8, 18),
        type: TransactionType.income,
        category: 'Salary',
        account: 'Savings',
      ),
    );

    await repository.addTransaction(
      ExpenseTransaction(
        id: 'groceries',
        title: 'Groceries',
        amount: 200,
        date: DateTime(2026, 8, 18),
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

    final viewAll = find.text('View All');

    await tester.ensureVisible(viewAll);

    await tester.pumpAndSettle();

    await tester.tap(viewAll);

    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);

    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Expense'));

    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('Salary'), findsNothing);
  });
}
