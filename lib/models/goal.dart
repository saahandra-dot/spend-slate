enum GoalIconKey {
  savings,
  vacation,
  home,
  car,
  education,
  emergency,
  laptop,
  gift,
  other,
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final GoalIconKey iconKey;
  final DateTime createdAt;
  final bool isCompleted;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.iconKey,
    required this.createdAt,
    required this.isCompleted,
  });

  /// Progress between 0.0 and 1.0.
  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }

    return (currentAmount / targetAmount)
        .clamp(
          0.0,
          1.0,
        )
        .toDouble();
  }

  double get progressPercentage {
    return progress * 100;
  }

  double get remainingAmount {
    final double remaining =
        targetAmount - currentAmount;

    return remaining > 0
        ? remaining
        : 0;
  }

  bool get hasReachedTarget {
    return currentAmount >=
        targetAmount;
  }

  int? daysUntilTarget({
    DateTime? now,
  }) {
    final DateTime? target =
        targetDate;

    if (target == null) {
      return null;
    }

    final DateTime current =
        now ?? DateTime.now();

    final DateTime today =
        DateTime(
      current.year,
      current.month,
      current.day,
    );

    final DateTime normalizedTarget =
        DateTime(
      target.year,
      target.month,
      target.day,
    );

    return normalizedTarget
        .difference(
          today,
        )
        .inDays;
  }

  bool isOverdue({
    DateTime? now,
  }) {
    if (isCompleted) {
      return false;
    }

    final int? days =
        daysUntilTarget(
      now: now,
    );

    return days != null &&
        days < 0;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
    GoalIconKey? iconKey,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount:
          targetAmount ??
              this.targetAmount,
      currentAmount:
          currentAmount ??
              this.currentAmount,
      targetDate:
          clearTargetDate
              ? null
              : targetDate ??
                  this.targetDate,
      iconKey:
          iconKey ??
              this.iconKey,
      createdAt:
          createdAt ??
              this.createdAt,
      isCompleted:
          isCompleted ??
              this.isCompleted,
    );
  }
}