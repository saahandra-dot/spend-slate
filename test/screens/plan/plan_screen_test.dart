import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/database/app_database.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/plan/plan_screen.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/providers/budget_provider.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Plan shows empty Goal state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Plan'), findsOneWidget);

    expect(find.text('Goals'), findsOneWidget);

    expect(find.text('No goals yet'), findsOneWidget);

    expect(find.text('Budgets'), findsOneWidget);

    expect(find.text('No budgets yet'), findsOneWidget);
  });

  testWidgets('Add Goal opens Goal form', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final Finder addGoalButton = find.widgetWithText(FilledButton, 'Add Goal');

    expect(addGoalButton, findsOneWidget);

    await tester.ensureVisible(addGoalButton);

    await tester.tap(addGoalButton);

    await tester.pumpAndSettle();

    expect(find.text('Add Goal'), findsOneWidget);

    expect(find.byKey(const Key('goalNameField')), findsOneWidget);

    expect(find.byKey(const Key('goalTargetAmountField')), findsOneWidget);

    expect(find.byKey(const Key('goalCurrentAmountField')), findsOneWidget);
  });

  testWidgets('creates Goal and displays it on Plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // -------------------------
    // OPEN ADD GOAL
    // -------------------------

    final Finder addGoalButton = find.widgetWithText(FilledButton, 'Add Goal');

    expect(addGoalButton, findsOneWidget);

    await tester.ensureVisible(addGoalButton);

    await tester.tap(addGoalButton);

    await tester.pumpAndSettle();

    // -------------------------
    // FIND FORM FIELDS
    // -------------------------

    final Finder nameField = find.byKey(const Key('goalNameField'));

    final Finder targetAmountField = find.byKey(
      const Key('goalTargetAmountField'),
    );

    final Finder currentAmountField = find.byKey(
      const Key('goalCurrentAmountField'),
    );

    expect(nameField, findsOneWidget);

    expect(targetAmountField, findsOneWidget);

    expect(currentAmountField, findsOneWidget);

    // -------------------------
    // ENTER VALUES
    // -------------------------

    await tester.enterText(nameField, 'Vacation');

    await tester.enterText(targetAmountField, '10000');

    await tester.enterText(currentAmountField, '2500');

    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    // -------------------------
    // SCROLL GOAL FORM
    // -------------------------

    final Finder goalFormList = find.byKey(const Key('goalFormList'));

    expect(goalFormList, findsOneWidget);

    await tester.drag(goalFormList, const Offset(0, -450));

    await tester.pumpAndSettle();

    await tester.drag(goalFormList, const Offset(0, -450));

    await tester.pumpAndSettle();

    // -------------------------
    // SAVE
    // -------------------------

    final Finder saveButton = find.byKey(const Key('saveGoalButton'));

    expect(saveButton, findsOneWidget);

    await tester.ensureVisible(saveButton);

    await tester.pumpAndSettle();

    await tester.tap(saveButton);

    await tester.pumpAndSettle();

    // -------------------------
    // VERIFY RETURN TO PLAN
    // -------------------------

    expect(find.text('Plan'), findsOneWidget);

    expect(find.text('Vacation'), findsOneWidget);

    expect(find.text('\$2,500.00 of \$10,000.00'), findsOneWidget);

    expect(find.text('No goals yet'), findsNothing);
  });

  testWidgets('Add Budget opens Budget form', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final Finder addBudget = find.widgetWithText(FilledButton, 'Add Budget');

    await tester.ensureVisible(addBudget);

    expect(addBudget, findsOneWidget);

    await tester.tap(addBudget);

    await tester.pumpAndSettle();

    expect(find.text('Add Budget'), findsOneWidget);

    expect(find.byKey(const Key('budgetCategoryField')), findsOneWidget);

    expect(find.byKey(const Key('budgetLimitField')), findsOneWidget);
  });

  testWidgets('Plan displays saved Budget', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );

    addTearDown(container.dispose);

    await container
        .read(budgetsProvider.notifier)
        .addBudget(
          MonthlyBudget(
            id: 'budget-groceries-test',
            categoryId: 'expense-groceries',
            limitAmount: 5000,
            month: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('\$5,000.00'), findsOneWidget);
  });
}
