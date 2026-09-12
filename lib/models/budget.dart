enum BudgetStatus { onTrack, nearLimit, atLimit, overBudget }

class MonthlyBudget {
  final String id;
  final String categoryId;
  final double limitAmount;
  final DateTime month;
  final DateTime createdAt;

  const MonthlyBudget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.createdAt,
  });

  MonthlyBudget copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    DateTime? month,
    DateTime? createdAt,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BudgetUsage {
  final MonthlyBudget budget;
  final double spentAmount;
  final int transactionCount;

  const BudgetUsage({
    required this.budget,
    required this.spentAmount,
    required this.transactionCount,
  });

  double get remainingAmount {
    final double remaining = budget.limitAmount - spentAmount;

    return remaining > 0 ? remaining : 0;
  }

  double get amountOver {
    final double over = spentAmount - budget.limitAmount;

    return over > 0 ? over : 0;
  }

  double get progress {
    if (budget.limitAmount <= 0) {
      return 0;
    }

    return (spentAmount / budget.limitAmount).clamp(0.0, 1.0).toDouble();
  }

  double get percentage {
    if (budget.limitAmount <= 0) {
      return 0;
    }

    return (spentAmount / budget.limitAmount) * 100;
  }

  bool get isOverBudget {
    return spentAmount > budget.limitAmount;
  }

  bool get hasReachedLimit {
    return spentAmount >= budget.limitAmount;
  }

  BudgetStatus get status {
    if (spentAmount > budget.limitAmount) {
      return BudgetStatus.overBudget;
    }

    if (spentAmount >= budget.limitAmount) {
      return BudgetStatus.atLimit;
    }

    if (percentage >= 80) {
      return BudgetStatus.nearLimit;
    }

    return BudgetStatus.onTrack;
  }
}

class BudgetMonthSummary {
  final double totalLimit;
  final double totalSpent;
  final int budgetCount;

  const BudgetMonthSummary({
    required this.totalLimit,
    required this.totalSpent,
    required this.budgetCount,
  });

  factory BudgetMonthSummary.fromUsages(List<BudgetUsage> usages) {
    final double totalLimit = usages.fold(
      0.0,
      (total, usage) => total + usage.budget.limitAmount,
    );

    final double totalSpent = usages.fold(
      0.0,
      (total, usage) => total + usage.spentAmount,
    );

    return BudgetMonthSummary(
      totalLimit: totalLimit,
      totalSpent: totalSpent,
      budgetCount: usages.length,
    );
  }

  double get availableAmount {
    final double available = totalLimit - totalSpent;

    return available > 0 ? available : 0;
  }

  double get amountOver {
    final double over = totalSpent - totalLimit;

    return over > 0 ? over : 0;
  }

  double get progress {
    if (totalLimit <= 0) {
      return 0;
    }

    return (totalSpent / totalLimit).clamp(0.0, 1.0).toDouble();
  }

  double get percentage {
    if (totalLimit <= 0) {
      return 0;
    }

    return (totalSpent / totalLimit) * 100;
  }

  bool get isOverBudget {
    return totalSpent > totalLimit;
  }
}

class BudgetAttentionSummary {
  final int onTrackCount;
  final int nearLimitCount;
  final int atLimitCount;
  final int overBudgetCount;

  const BudgetAttentionSummary({
    required this.onTrackCount,
    required this.nearLimitCount,
    required this.atLimitCount,
    required this.overBudgetCount,
  });

  factory BudgetAttentionSummary.fromUsages(List<BudgetUsage> usages) {
    int onTrack = 0;
    int nearLimit = 0;
    int atLimit = 0;
    int overBudget = 0;

    for (final usage in usages) {
      switch (usage.status) {
        case BudgetStatus.onTrack:
          onTrack++;

        case BudgetStatus.nearLimit:
          nearLimit++;

        case BudgetStatus.atLimit:
          atLimit++;

        case BudgetStatus.overBudget:
          overBudget++;
      }
    }

    return BudgetAttentionSummary(
      onTrackCount: onTrack,
      nearLimitCount: nearLimit,
      atLimitCount: atLimit,
      overBudgetCount: overBudget,
    );
  }

  int get attentionCount {
    return nearLimitCount + atLimitCount + overBudgetCount;
  }

  bool get hasAttention {
    return attentionCount > 0;
  }

  bool get hasOverBudget {
    return overBudgetCount > 0;
  }

  bool get hasReachedLimit {
    return atLimitCount > 0;
  }
}
