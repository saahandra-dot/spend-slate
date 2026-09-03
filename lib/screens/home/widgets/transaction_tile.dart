import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/transaction.dart';
import '../../../core/data/category_catalog.dart';
import '../../../core/theme/category_visuals.dart';

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

    final category = CategoryCatalog.find(
      transaction.category,
      transaction.type,
    );

    final IconData categoryIcon =
        category?.iconKey.iconData ?? Icons.receipt_rounded;

    final Color categoryColor =
        category?.colorKey.color ?? AppColors.textSecondary;

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
}
