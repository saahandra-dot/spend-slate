import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final ExpenseTransaction transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == TransactionType.expense;

    final IconData categoryIcon = _getCategoryIcon(transaction.category);

    final Color categoryColor = _getCategoryColor(transaction.category);

    final List<String> details = [
      if (transaction.account != null && transaction.account!.trim().isNotEmpty)
        transaction.account!,
      if (showDate) AppFormatters.shortDate(transaction.date),
    ];

    final String subtitle = details.join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 22),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              _formattedAmount(transaction),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isExpense ? AppColors.expense : AppColors.positive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedAmount(ExpenseTransaction transaction) {
    final String amount = AppFormatters.currency(transaction.amount);

    if (transaction.type == TransactionType.income) {
      return '+$amount';
    }

    return '-$amount';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cash':
        return Icons.account_balance_wallet_rounded;

      case 'cafe':
      case 'cafes':
        return Icons.local_cafe_rounded;

      case 'groceries':
        return Icons.shopping_basket_rounded;

      case 'clothing':
        return Icons.checkroom_rounded;

      case 'transport':
        return Icons.directions_car_rounded;

      case 'entertainment':
        return Icons.movie_rounded;

      case 'health':
        return Icons.favorite_rounded;

      case 'education':
        return Icons.school_rounded;

      case 'bills':
        return Icons.receipt_long_rounded;

      case 'salary':
        return Icons.payments_rounded;

      case 'freelance':
        return Icons.work_rounded;

      case 'business':
        return Icons.business_center_rounded;

      case 'investment':
        return Icons.trending_up_rounded;

      case 'gift':
        return Icons.card_giftcard_rounded;

      case 'other income':
        return Icons.attach_money_rounded;

      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cash':
        return AppColors.primaryPurple;

      case 'cafe':
      case 'cafes':
        return AppColors.blue;

      case 'groceries':
        return AppColors.green;

      case 'clothing':
        return AppColors.orange;

      case 'transport':
        return AppColors.income;

      case 'entertainment':
        return AppColors.primaryPurple;

      case 'health':
        return AppColors.expense;

      case 'education':
        return AppColors.blue;

      case 'bills':
        return AppColors.orange;

      case 'salary':
      case 'freelance':
      case 'business':
      case 'investment':
      case 'gift':
      case 'other income':
        return AppColors.positive;

      default:
        return AppColors.textSecondary;
    }
  }
}
