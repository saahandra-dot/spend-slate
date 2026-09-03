import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'app_colors.dart';

extension CategoryIconKeyVisual on CategoryIconKey {
  IconData get iconData {
    switch (this) {
      case CategoryIconKey.groceries:
        return Icons.shopping_basket_rounded;

      case CategoryIconKey.cafe:
        return Icons.local_cafe_rounded;

      case CategoryIconKey.clothing:
        return Icons.checkroom_rounded;

      case CategoryIconKey.transport:
        return Icons.directions_car_rounded;

      case CategoryIconKey.entertainment:
        return Icons.movie_rounded;

      case CategoryIconKey.health:
        return Icons.favorite_rounded;

      case CategoryIconKey.education:
        return Icons.school_rounded;

      case CategoryIconKey.bills:
        return Icons.receipt_long_rounded;

      case CategoryIconKey.salary:
        return Icons.payments_rounded;

      case CategoryIconKey.freelance:
        return Icons.work_rounded;

      case CategoryIconKey.business:
        return Icons.business_center_rounded;

      case CategoryIconKey.investment:
        return Icons.trending_up_rounded;

      case CategoryIconKey.gift:
        return Icons.card_giftcard_rounded;

      case CategoryIconKey.money:
        return Icons.attach_money_rounded;

      case CategoryIconKey.other:
        return Icons.category_rounded;
    }
  }
}

extension CategoryColorKeyVisual on CategoryColorKey {
  Color get color {
    switch (this) {
      case CategoryColorKey.purple:
        return AppColors.primaryPurple;

      case CategoryColorKey.blue:
        return AppColors.blue;

      case CategoryColorKey.green:
        return AppColors.green;

      case CategoryColorKey.orange:
        return AppColors.orange;

      case CategoryColorKey.red:
        return AppColors.expense;

      case CategoryColorKey.positive:
        return AppColors.positive;

      case CategoryColorKey.secondary:
        return AppColors.textSecondary;
    }
  }
}
