import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import 'transaction_tile.dart';

class TransactionsSection extends ConsumerWidget {
  const TransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ExpenseTransaction> transactions = ref.watch(
      transactionsProvider,
    );

    final double totalExpenses = ref.watch(totalExpensesProvider);

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

          for (int index = 0; index < transactions.length; index++) ...[
            TransactionTile(transaction: transactions[index]),

            if (index != transactions.length - 1) const Divider(height: 1),
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
