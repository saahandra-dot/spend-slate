import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/screens/home/widgets/balance_header.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 120
        ),
        child: Column(
          children: [
            BalanceHeader()
          ]
        )
      )
    );
  }
}