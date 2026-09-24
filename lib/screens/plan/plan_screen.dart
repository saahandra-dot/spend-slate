import 'package:expense_tracker/core/theme/theme_context.dart';
import 'package:expense_tracker/core/widgets/app_currency_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/month_picker_sheet.dart';
import '../../providers/period_provider.dart';
import '../../core/theme/goal_visuals.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import '../../core/data/category_catalog.dart';
import '../../core/theme/category_visuals.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/theme/budget_status_visuals.dart';
import 'budget_form_screen.dart';
import 'goal_form_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  Future<void> _openGoalForm(BuildContext context, {SavingsGoal? goal}) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => GoalFormScreen(goal: goal)));
  }

  Future<void> _openBudgetForm(
    BuildContext context, {
    required DateTime selectedMonth,
    MonthlyBudget? budget,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BudgetFormScreen(budget: budget, initialMonth: selectedMonth),
      ),
    );
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    MonthlyBudget budget,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete budget?'),
          content: const Text(
            'This monthly budget will be removed. '
            'Your transactions will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(budgetsProvider.notifier).removeBudget(budget.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete budget. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete goal?'),
          content: Text(
            'Delete "${goal.name}"? '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(goalsProvider.notifier).removeGoal(goal.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete goal. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedMonth = ref.watch(selectedMonthProvider);
    final goalsAsync = ref.watch(goalsProvider);

    final List<SavingsGoal> activeGoals = ref.watch(activeGoalsProvider);

    final List<SavingsGoal> completedGoals = ref.watch(completedGoalsProvider);

    final budgetUsageAsync = ref.watch(selectedMonthBudgetUsageProvider);

    final budgetAttentionAsync = ref.watch(
      selectedMonthBudgetAttentionProvider,
    );

    final budgetSummaryAsync = ref.watch(selectedMonthBudgetSummaryProvider);

    final categoriesAsync = ref.watch(categoriesProvider);

    final List<AppCategory> categoryDefinitions =
        categoriesAsync.value ?? CategoryCatalog.categories;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PlanHeader(),

              const SizedBox(height: 26),

              _PlanOverviewCard(selectedMonth: selectedMonth),

              const SizedBox(height: 34),

              _SectionHeader(
                title: 'Goals',
                subtitle: 'Save toward the things that matter',
                icon: Icons.flag_rounded,
                actionLabel: 'Add Goal',
                onAction: () {
                  _openGoalForm(context);
                },
              ),

              const SizedBox(height: 16),

              goalsAsync.when(
                loading: () {
                  return const _GoalLoadingState();
                },
                error: (error, stackTrace) {
                  return _GoalErrorState(
                    onRetry: () {
                      ref.invalidate(goalsProvider);
                    },
                  );
                },
                data: (goals) {
                  if (goals.isEmpty) {
                    return _EmptyPlanCard(
                      icon: Icons.track_changes_rounded,
                      title: 'No goals yet',
                      description:
                          'Create your first savings goal and track your progress over time.',
                      buttonLabel: 'Add Goal',
                      onPressed: () {
                        _openGoalForm(context);
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeGoals.isNotEmpty)
                        _GoalsList(
                          goals: activeGoals,
                          onEdit: (goal) {
                            _openGoalForm(context, goal: goal);
                          },
                          onDelete: (goal) {
                            _deleteGoal(context, ref, goal);
                          },
                        ),

                      if (activeGoals.isEmpty && completedGoals.isNotEmpty)
                        const _AllGoalsCompletedCard(),

                      if (completedGoals.isNotEmpty) ...[
                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7F7F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.positive,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              'Completed Goals',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: context.appTextPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _GoalsList(
                          goals: completedGoals,
                          onEdit: (goal) {
                            _openGoalForm(context, goal: goal);
                          },
                          onDelete: (goal) {
                            _deleteGoal(context, ref, goal);
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              _BudgetSectionHeader(
                selectedMonth: selectedMonth,
                onMonthTap: () async {
                  final DateTime? month = await showAppMonthPicker(
                    context: context,
                    initialMonth: selectedMonth,
                  );

                  if (month == null) {
                    return;
                  }

                  ref.read(selectedMonthProvider.notifier).setMonth(month);
                },
                onAddBudget: () {
                  _openBudgetForm(context, selectedMonth: selectedMonth);
                },
              ),

              const SizedBox(height: 16),

              budgetSummaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (summary) {
                  if (summary.budgetCount == 0) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      _MonthlyBudgetSummaryCard(
                        summary: summary,
                        attention:
                            budgetAttentionAsync.value ??
                            const BudgetAttentionSummary(
                              onTrackCount: 0,
                              nearLimitCount: 0,
                              atLimitCount: 0,
                              overBudgetCount: 0,
                            ),
                        selectedMonth: selectedMonth,
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              budgetUsageAsync.when(
                loading: () {
                  return const _BudgetLoadingState();
                },
                error: (error, stackTrace) {
                  return _BudgetErrorState(
                    onRetry: () {
                      ref.invalidate(budgetsProvider);
                    },
                  );
                },
                data: (usages) {
                  if (usages.isEmpty) {
                    return _EmptyPlanCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No budgets this month',
                      description:
                          'Create a category budget for '
                          '${AppFormatters.monthYear(selectedMonth)}.',
                      buttonLabel: 'Add Budget',
                      onPressed: () {
                        _openBudgetForm(context, selectedMonth: selectedMonth);
                      },
                    );
                  }

                  return _BudgetList(
                    usages: usages,
                    categories: categoryDefinitions,
                    onEdit: (budget) {
                      _openBudgetForm(
                        context,
                        selectedMonth: selectedMonth,
                        budget: budget,
                      );
                    },
                    onDelete: (budget) {
                      _deleteBudget(context, ref, budget);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'Plan your savings goals and monthly spending.',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: context.appTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _PlanOverviewCard extends StatelessWidget {
  final DateTime selectedMonth;

  const _PlanOverviewCard({required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_graph_rounded, color: Colors.white),
          ),

          const SizedBox(height: 18),

          const Text(
            'Build your financial plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Goals help you save toward future purchases, while budgets help you control monthly spending.',
            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: Colors.white,
                ),

                const SizedBox(width: 7),

                Text(
                  'Budget period: '
                  '${AppFormatters.monthYear(selectedMonth)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.appSoftPrimary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: AppColors.primaryPurple),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: context.appTextSecondary),
              ),
            ],
          ),
        ),

        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _BudgetSectionHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onMonthTap;
  final VoidCallback onAddBudget;

  const _BudgetSectionHeader({
    required this.selectedMonth,
    required this.onMonthTap,
    required this.onAddBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.appSoftPrimary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 21,
                color: AppColors.primaryPurple,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.appTextPrimary,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Set limits for monthly spending',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            TextButton.icon(
              onPressed: onAddBudget,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Budget'),
            ),
          ],
        ),

        const SizedBox(height: 14),

        _BudgetMonthSelector(selectedMonth: selectedMonth, onTap: onMonthTap),
      ],
    );
  }
}

class _MonthlyBudgetSummaryCard extends StatelessWidget {
  final BudgetMonthSummary summary;
  final DateTime selectedMonth;
  final BudgetAttentionSummary attention;

  const _MonthlyBudgetSummaryCard({
    required this.summary,
    required this.selectedMonth,
    required this.attention,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.appSoftPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppFormatters.monthYear(selectedMonth)} Budget',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.appTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      summary.budgetCount == 1
                          ? '1 category budget'
                          : '${summary.budgetCount} category budgets',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _BudgetSummaryMetric(
                  label: 'Total limits',
                  value: AppCurrencyScope.format(context, summary.totalLimit),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _BudgetSummaryMetric(
                  label: 'Spent',
                  value: AppCurrencyScope.format(context, summary.totalSpent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                'Monthly budget used',
                style: TextStyle(fontSize: 12, color: context.appTextSecondary),
              ),

              const Spacer(),

              Text(
                '${summary.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 10,
              backgroundColor: context.appDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryPurple,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.appBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 19,
                  color: AppColors.primaryPurple,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appTextSecondary,
                    ),
                  ),
                ),

                Text(
                  AppCurrencyScope.format(context, summary.availableAmount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (attention.hasAttention) ...[
            const SizedBox(height: 14),

            _BudgetAttentionBanner(attention: attention),
          ],
        ],
      ),
    );
  }
}

class _BudgetAttentionBanner extends StatelessWidget {
  final BudgetAttentionSummary attention;

  const _BudgetAttentionBanner({required this.attention});

  @override
  Widget build(BuildContext context) {
    final bool severe = attention.hasOverBudget || attention.hasReachedLimit;

    final Color color = severe ? AppColors.expense : AppColors.warning;

    final String title;

    if (attention.attentionCount == 1) {
      title = '1 budget needs attention';
    } else {
      title = '${attention.attentionCount} budgets need attention';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            severe ? Icons.warning_rounded : Icons.warning_amber_rounded,
            size: 20,
            color: color,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _detailText(),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: context.appTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _detailText() {
    final parts = <String>[];

    if (attention.nearLimitCount > 0) {
      parts.add('${attention.nearLimitCount} near limit');
    }

    if (attention.atLimitCount > 0) {
      parts.add('${attention.atLimitCount} at limit');
    }

    if (attention.overBudgetCount > 0) {
      parts.add('${attention.overBudgetCount} over budget');
    }

    return parts.join(' • ');
  }
}

class _BudgetSummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetSummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.appTextSecondary),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _BudgetMonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onTap;

  const _BudgetMonthSelector({
    required this.selectedMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appDivider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: AppColors.primaryPurple,
              ),

              const SizedBox(width: 10),

              Text(
                'Budget month',
                style: TextStyle(fontSize: 13, color: context.appTextSecondary),
              ),

              const Spacer(),

              Text(
                AppFormatters.monthYear(selectedMonth),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),

              const SizedBox(width: 4),

              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.appTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _EmptyPlanCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.appSoftPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.primaryPurple),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.appTextSecondary,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _GoalsList extends StatelessWidget {
  final List<SavingsGoal> goals;

  final ValueChanged<SavingsGoal> onEdit;

  final ValueChanged<SavingsGoal> onDelete;

  const _GoalsList({
    required this.goals,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < goals.length; index++) ...[
          _GoalCard(
            goal: goals[index],
            onEdit: () {
              onEdit(goals[index]);
            },
            onDelete: () {
              onDelete(goals[index]);
            },
          ),

          if (index != goals.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal.progress;

    final double percentage = goal.progressPercentage;

    final bool completed = goal.isCompleted;

    final bool overdue = goal.isOverdue();

    final Color statusColor = completed
        ? AppColors.positive
        : overdue
        ? AppColors.expense
        : AppColors.primaryPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: completed
              ? AppColors.positive.withValues(alpha: 0.25)
              : overdue
              ? AppColors.expense.withValues(alpha: 0.25)
              : context.appDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  completed ? Icons.check_rounded : goal.iconKey.iconData,
                  color: statusColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.appTextPrimary,
                      ),
                    ),

                    if (completed) ...[
                      const SizedBox(height: 3),
                      const Text(
                        'Goal completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.positive,
                        ),
                      ),
                    ] else if (overdue) ...[
                      const SizedBox(height: 3),
                      const Text(
                        'Goal overdue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();

                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 19),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${AppCurrencyScope.format(context, goal.currentAmount)} '
                  'of ${AppCurrencyScope.format(context, goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: context.appDivider,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(
                completed
                    ? Icons.check_circle_outline_rounded
                    : Icons.savings_outlined,
                size: 17,
                color: statusColor,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  completed
                      ? 'Target reached'
                      : '${AppCurrencyScope.format(context, goal.remainingAmount)} remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: completed
                        ? AppColors.positive
                        : context.appTextSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(height: 1),

          const SizedBox(height: 14),

          _GoalDeadline(goal: goal),
        ],
      ),
    );
  }
}

class _GoalDeadline extends StatelessWidget {
  final SavingsGoal goal;

  const _GoalDeadline({required this.goal});

  @override
  Widget build(BuildContext context) {
    final DateTime? targetDate = goal.targetDate;

    if (targetDate == null) {
      return Row(
        children: [
          Icon(Icons.event_outlined, size: 17, color: context.appTextSecondary),

          SizedBox(width: 7),

          Text(
            'No target date',
            style: TextStyle(fontSize: 12, color: context.appTextSecondary),
          ),
        ],
      );
    }

    final int days = goal.daysUntilTarget() ?? 0;

    final bool overdue = goal.isOverdue();

    final String relativeText;

    if (goal.isCompleted) {
      relativeText = 'Goal completed';
    } else if (days < 0) {
      final int overdueDays = days.abs();

      relativeText = overdueDays == 1
          ? '1 day overdue'
          : '$overdueDays days overdue';
    } else if (days == 0) {
      relativeText = 'Due today';
    } else if (days == 1) {
      relativeText = '1 day remaining';
    } else {
      relativeText = '$days days remaining';
    }

    final Color color = goal.isCompleted
        ? AppColors.positive
        : overdue
        ? AppColors.expense
        : context.appTextSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.event_outlined, size: 17, color: color),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target: '
                '${AppFormatters.date(targetDate)}',
                style: TextStyle(fontSize: 12, color: context.appTextSecondary),
              ),

              const SizedBox(height: 3),

              Text(
                relativeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllGoalsCompletedCard extends StatelessWidget {
  const _AllGoalsCompletedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.positive.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.positive.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded, color: AppColors.positive),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All goals completed',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Create another goal whenever you are ready.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalLoadingState extends StatelessWidget {
  const _GoalLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GoalErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _GoalErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 38,
            color: AppColors.expense,
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load goals',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Text(
            'Please try loading your goals again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appTextSecondary),
          ),

          const SizedBox(height: 14),

          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _BudgetList extends StatelessWidget {
  final List<BudgetUsage> usages;

  final List<AppCategory> categories;

  final ValueChanged<MonthlyBudget> onEdit;

  final ValueChanged<MonthlyBudget> onDelete;

  const _BudgetList({
    required this.usages,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < usages.length; index++) ...[
          _BudgetCard(
            usage: usages[index],
            category: CategoryCatalog.findById(
              categories,
              usages[index].budget.categoryId,
            ),
            onEdit: () {
              onEdit(usages[index].budget);
            },
            onDelete: () {
              onDelete(usages[index].budget);
            },
          ),

          if (index != usages.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetUsage usage;
  final AppCategory? category;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.usage,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final MonthlyBudget budget = usage.budget;

    final BudgetStatus status = usage.status;

    final Color statusColor = status.color;

    final Color categoryColor =
        category?.colorKey.color ?? AppColors.primaryPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CATEGORY HEADER
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  category?.iconKey.iconData ?? Icons.category_rounded,
                  color: categoryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Unknown Category',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.appTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      AppFormatters.monthYear(budget.month),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),

                    Text(
                      usage.transactionCount == 1
                          ? '1 expense'
                          : '${usage.transactionCount} expenses',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),

                    _BudgetStatusBadge(status: status),
                  ],
                ),
              ),

              // const SizedBox(height: 7),

              // _BudgetStatusBadge(status: status),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;

                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 19),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent this month',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appTextSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      AppCurrencyScope.format(context, usage.spentAmount),
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: context.appTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Limit',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    AppCurrencyScope.format(context, budget.limitAmount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                'Budget used',
                style: TextStyle(fontSize: 12, color: context.appTextSecondary),
              ),

              const Spacer(),

              Text(
                '${usage.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: usage.progress,
              minHeight: 9,
              backgroundColor: context.appDivider,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 14),

          _BudgetRemainingIndicator(usage: usage),
        ],
      ),
    );
  }
}

class _BudgetRemainingIndicator extends StatelessWidget {
  final BudgetUsage usage;

  const _BudgetRemainingIndicator({required this.usage});

  @override
  Widget build(BuildContext context) {
    final BudgetStatus status = usage.status;

    final Color color = status.color;

    final String label;
    final String amountText;
    final IconData icon;

    switch (status) {
      case BudgetStatus.onTrack:
        label = 'Available';
        amountText = AppCurrencyScope.format(context, usage.remainingAmount);
        icon = Icons.account_balance_wallet_outlined;

      case BudgetStatus.nearLimit:
        label = 'Almost at your limit';
        amountText =
            '${AppCurrencyScope.format(context, usage.remainingAmount)} left';
        icon = Icons.warning_amber_rounded;

      case BudgetStatus.atLimit:
        label = 'No budget remaining';
        amountText = AppCurrencyScope.format(context, 0);
        icon = Icons.error_outline_rounded;

      case BudgetStatus.overBudget:
        label = 'Over budget';
        amountText =
            '${AppCurrencyScope.format(context, usage.amountOver)} over';
        icon = Icons.warning_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),

          const SizedBox(width: 8),

          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: color)),
          ),

          Text(
            amountText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStatusBadge extends StatelessWidget {
  final BudgetStatus status;

  const _BudgetStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: color),

          const SizedBox(width: 5),

          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetLoadingState extends StatelessWidget {
  const _BudgetLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _BudgetErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _BudgetErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 38,
            color: AppColors.expense,
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load budgets',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
