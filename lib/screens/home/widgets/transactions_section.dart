import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/screens/home/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';

class TransactionsSection extends StatelessWidget {
  const TransactionsSection({super.key});

  static final List<ExpenseTransaction> _transactions = [
    ExpenseTransaction(
      id: '1',
      title: 'Cash, EUR',
      amount: 354.25,
      date: DateTime(2026, 1, 12),
      type: TransactionType.expense,
      category: 'Cash',
      account: 'Red Card',
    ),
    ExpenseTransaction(
      id: '2',
      title: 'Cafes',
      amount: 12.49,
      date: DateTime(2026, 1, 12),
      type: TransactionType.expense,
      category: 'Cafe',
      account: 'Vacation',
    ),
    ExpenseTransaction(
      id: '3',
      title: 'Groceries',
      amount: 86.40,
      date: DateTime(2026, 1, 12),
      type: TransactionType.expense,
      category: 'Groceries',
      account: 'Debit Card',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double totalExpenses = _transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0, (total, transaction) => total + transaction.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TransactionsHeader(),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monday, 12 January 2026',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const Text(
                'Total ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              Text(
                '\$${totalExpenses.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          for (int index = 0; index < _transactions.length; index++) ...[
            TransactionTile(transaction: _transactions[index]),

            if (index != _transactions.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  const _TransactionsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        Spacer(),

        Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryPurple),

        SizedBox(width: 12),

        Icon(Icons.schedule_rounded, size: 18, color: AppColors.primaryPurple),

        SizedBox(width: 8),

        Text(
          'For the Period',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }
}
