import 'package:flutter/material.dart';

import '../../models/budget.dart';
import 'app_colors.dart';

extension BudgetStatusVisual on BudgetStatus {
  Color get color {
    switch (this) {
      case BudgetStatus.onTrack:
        return AppColors.positive;

      case BudgetStatus.nearLimit:
        return AppColors.warning;

      case BudgetStatus.atLimit:
        return AppColors.expense;

      case BudgetStatus.overBudget:
        return AppColors.expense;
    }
  }

  IconData get icon {
    switch (this) {
      case BudgetStatus.onTrack:
        return Icons.check_circle_outline_rounded;

      case BudgetStatus.nearLimit:
        return Icons.warning_amber_rounded;

      case BudgetStatus.atLimit:
        return Icons.error_outline_rounded;

      case BudgetStatus.overBudget:
        return Icons.warning_rounded;
    }
  }

  String get label {
    switch (this) {
      case BudgetStatus.onTrack:
        return 'On track';

      case BudgetStatus.nearLimit:
        return 'Near your limit';

      case BudgetStatus.atLimit:
        return 'Budget limit reached';

      case BudgetStatus.overBudget:
        return 'Over budget';
    }
  }
}
