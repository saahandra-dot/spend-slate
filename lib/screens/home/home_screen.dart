import 'package:expense_tracker/core/theme/theme_context.dart';
import 'package:expense_tracker/screens/home/widgets/transactions_section.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/screens/home/widgets/balance_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120),
        child: Column(children: [BalanceHeader(), TransactionsSection()]),
      ),
    );
  }
}
