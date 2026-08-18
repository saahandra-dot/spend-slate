import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../core/utils/app_formatters.dart';
import 'add_transaction_screen.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final ExpenseTransaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isExpense = transaction.type == TransactionType.expense;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primaryPurple,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${isExpense ? '-' : '+'}'
                    '${AppFormatters.currency(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: isExpense ? AppColors.expense : AppColors.positive,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Type',
                    value: isExpense ? 'Expense' : 'Income',
                  ),

                  const Divider(height: 28),

                  _DetailRow(label: 'Category', value: transaction.category),

                  const Divider(height: 28),

                  _DetailRow(
                    label: 'Account',
                    value: transaction.account ?? 'Not specified',
                  ),

                  const Divider(height: 28),

                  _DetailRow(
                    label: 'Date',
                    value: AppFormatters.date(transaction.date),
                  ),

                  if (transaction.note != null &&
                      transaction.note!.isNotEmpty) ...[
                    const Divider(height: 28),

                    _DetailRow(label: 'Note', value: transaction.note!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _deleteTransaction(context, ref);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _editTransaction(context);
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTransaction(BuildContext context) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (changed == true) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteTransaction(BuildContext context, WidgetRef ref) async {
    final bool shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete transaction?'),
              content: const Text(
                'This transaction will be permanently removed.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.expense,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(transactionsProvider.notifier)
          .removeTransaction(transaction.id);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete transaction. Please try again.'),
        ),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
