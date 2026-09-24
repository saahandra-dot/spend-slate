import 'package:expense_tracker/core/theme/theme_context.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_currency_scope.dart';
import '../../../core/theme/app_colors.dart';

class MoneySummaryCard extends StatelessWidget {
  final double income;
  final double expenses;

  const MoneySummaryCard({
    super.key,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Your money',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: context.appTextSecondary,
              ),
              const Spacer(),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.appTextSecondary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.appTextSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MoneyItem(
                  title: 'Income',
                  amount: AppCurrencyScope.format(context, income),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                ),
              ),
              SizedBox(width: 18),
              SizedBox(
                height: 70,
                child: VerticalDivider(color: context.appDivider, width: 1),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _MoneyItem(
                  title: 'Expense',
                  amount: AppCurrencyScope.format(context, expenses),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyItem extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _MoneyItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13, color: context.appTextSecondary),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: context.appTextSecondary,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),
      ],
    );
  }
}
