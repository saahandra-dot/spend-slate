import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/app.dart';

void main() {
  testWidgets('Expense Tracker app loads successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
