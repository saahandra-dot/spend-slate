import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final ExpenseTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == TransactionType.expense;
    final Color categoryColor = _getCategoryColor(transaction.category);
    final IconData categoryIcon = _getCategoryIcon(transaction.category);

    return Padding(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (transaction.account != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        size: 14,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          transaction.account!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          Text(
            '${isExpense ? '-' : '+'}'
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isExpense ? AppColors.expense : AppColors.positive,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.fastfood_rounded;
    case 'transportation':
      return Icons.directions_car_rounded;
    case 'entertainment':
      return Icons.movie_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'health':
      return Icons.health_and_safety_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'travel':
      return Icons.flight_rounded;
    case 'utilities':
      return Icons.lightbulb_rounded;
    default:
      return Icons.category_rounded;
  }
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.green;
    case 'transportation':
      return AppColors.income;
    case 'entertainment':
      return AppColors.orange;
    case 'shopping':
      return AppColors.orange;
    case 'health':
      return AppColors.orange;
    case 'education':
      return AppColors.green;
    case 'travel':
      return AppColors.green;
    case 'utilities':
      return AppColors.blue;
    default:
      return AppColors.textSecondary;
  }
}
