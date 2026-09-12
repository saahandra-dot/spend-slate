import 'package:flutter/material.dart';

import '../../models/goal.dart';

extension GoalIconKeyVisual on GoalIconKey {
  IconData get iconData {
    switch (this) {
      case GoalIconKey.savings:
        return Icons.savings_rounded;

      case GoalIconKey.vacation:
        return Icons.flight_rounded;

      case GoalIconKey.home:
        return Icons.home_rounded;

      case GoalIconKey.car:
        return Icons.directions_car_rounded;

      case GoalIconKey.education:
        return Icons.school_rounded;

      case GoalIconKey.emergency:
        return Icons.health_and_safety_rounded;

      case GoalIconKey.laptop:
        return Icons.laptop_mac_rounded;

      case GoalIconKey.gift:
        return Icons.card_giftcard_rounded;

      case GoalIconKey.other:
        return Icons.flag_rounded;
    }
  }

  String get label {
    switch (this) {
      case GoalIconKey.savings:
        return 'Savings';

      case GoalIconKey.vacation:
        return 'Vacation';

      case GoalIconKey.home:
        return 'Home';

      case GoalIconKey.car:
        return 'Car';

      case GoalIconKey.education:
        return 'Education';

      case GoalIconKey.emergency:
        return 'Emergency';

      case GoalIconKey.laptop:
        return 'Laptop';

      case GoalIconKey.gift:
        return 'Gift';

      case GoalIconKey.other:
        return 'Other';
    }
  }
}
