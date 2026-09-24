import 'package:expense_tracker/core/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/category_catalog.dart';
import '../../../core/theme/category_visuals.dart';
import '../../../providers/category_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/transaction.dart';
import '../../../core/widgets/app_currency_scope.dart';

class TransactionTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isExpense = transaction.type == TransactionType.expense;

    final categories = ref.watch(categoriesForTypeProvider(transaction.type));

    final category = CategoryCatalog.findIn(
      categories,
      transaction.category,
      transaction.type,
    );

    final IconData categoryIcon =
        category?.iconKey.iconData ?? Icons.receipt_rounded;

    final Color categoryColor =
        category?.colorKey.color ?? context.appTextSecondary;

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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.appTextPrimary,
                    ),
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              _formattedAmount(context, transaction),
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

  String _formattedAmount(
    BuildContext context,
    ExpenseTransaction transaction,
  ) {
    final amount = AppCurrencyScope.format(context, transaction.amount);

    return transaction.type == TransactionType.income ? '+$amount' : '-$amount';
  }
}
