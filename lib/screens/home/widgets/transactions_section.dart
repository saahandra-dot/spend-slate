import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../providers/transaction_provider.dart';
import '../../transaction/add_transaction_screen.dart';
import '../../transaction/transaction_details_screen.dart';
import '../../transaction/all_transactions_screen.dart';
import 'transaction_tile.dart';

class TransactionsSection extends ConsumerWidget {
  const TransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TransactionsHeader(
            onViewAll: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AllTransactionsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          transactionsAsync.when(
            loading: () {
              return const _LoadingState();
            },

            error: (error, stackTrace) {
              return _ErrorState(
                onRetry: () {
                  ref.invalidate(transactionsProvider);
                },
              );
            },

            data: (transactions) {
              if (transactions.isEmpty) {
                return _EmptyTransactionsState(
                  onAddTransaction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                  },
                );
              }

              final previewTransactions = transactions.take(5).toList();

              final double totalExpenses = ref.watch(totalExpensesProvider);

              return Column(
                children: [
                  _TransactionsSummary(
                    transactionCount: transactions.length,
                    totalExpenses: totalExpenses,
                  ),

                  const SizedBox(height: 8),

                  for (
                    int index = 0;
                    index < previewTransactions.length;
                    index++
                  ) ...[
                    TransactionTile(
                      transaction: previewTransactions[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailsScreen(
                              transaction: previewTransactions[index],
                            ),
                          ),
                        );
                      },
                    ),

                    if (index != previewTransactions.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const _TransactionsHeader({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: onViewAll,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              SizedBox(width: 2),

              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionsSummary extends StatelessWidget {
  final int transactionCount;
  final double totalExpenses;

  const _TransactionsSummary({
    required this.transactionCount,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final String countLabel = transactionCount == 1
        ? '1 transaction'
        : '$transactionCount transactions';

    return Row(
      children: [
        Expanded(
          child: Text(
            countLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const Text(
          'Expenses ',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        Text(
          AppFormatters.currency(totalExpenses),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const _EmptyTransactionsState({required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.lightPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryPurple,
              size: 32,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No transactions yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Track your spending and income '
            'by adding your first transaction.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: 190,
            child: ElevatedButton.icon(
              onPressed: onAddTransaction,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Transaction',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.expense,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Unable to load transactions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Something went wrong while '
            'loading your transactions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
