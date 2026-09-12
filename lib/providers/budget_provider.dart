import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget.dart';
import '../repositories/budget_repository.dart';
import 'period_provider.dart';
import 'transaction_provider.dart';
import '../core/data/category_catalog.dart';
import '../core/utils/budget_calculator.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'category_provider.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return BudgetRepository(database);
});

final budgetsProvider =
    AsyncNotifierProvider<BudgetController, List<MonthlyBudget>>(
      BudgetController.new,
    );

final selectedMonthBudgetsProvider = Provider<AsyncValue<List<MonthlyBudget>>>((
  ref,
) {
  final DateTime selectedMonth = ref.watch(selectedMonthProvider);

  final budgetsAsync = ref.watch(budgetsProvider);

  return budgetsAsync.whenData((budgets) {
    return budgets.where((budget) {
      return budget.month.year == selectedMonth.year &&
          budget.month.month == selectedMonth.month;
    }).toList();
  });
});

final selectedMonthBudgetUsageProvider =
    Provider<AsyncValue<List<BudgetUsage>>>((ref) {
      final budgetsAsync = ref.watch(selectedMonthBudgetsProvider);

      final categoriesAsync = ref.watch(categoriesProvider);

      final transactionsAsync = ref.watch(monthlyTransactionsProvider);

      return budgetsAsync.when(
        loading: () {
          return const AsyncValue<List<BudgetUsage>>.loading();
        },
        error: (error, stackTrace) {
          return AsyncValue<List<BudgetUsage>>.error(error, stackTrace);
        },
        data: (budgets) {
          return categoriesAsync.when(
            loading: () {
              return const AsyncValue<List<BudgetUsage>>.loading();
            },
            error: (error, stackTrace) {
              return AsyncValue<List<BudgetUsage>>.error(error, stackTrace);
            },
            data: (categories) {
              return transactionsAsync.when(
                loading: () {
                  return const AsyncValue<List<BudgetUsage>>.loading();
                },
                error: (error, stackTrace) {
                  return AsyncValue<List<BudgetUsage>>.error(error, stackTrace);
                },
                data: (transactions) {
                  final List<BudgetUsage> usages = budgets.map((budget) {
                    final AppCategory? category = CategoryCatalog.findById(
                      categories,
                      budget.categoryId,
                    );

                    return BudgetCalculator.calculateUsage(
                      budget: budget,
                      category: category,
                      transactions: transactions,
                    );
                  }).toList();

                  return AsyncValue<List<BudgetUsage>>.data(usages);
                },
              );
            },
          );
        },
      );
    });

final selectedMonthBudgetSummaryProvider =
    Provider<AsyncValue<BudgetMonthSummary>>((ref) {
      final usageAsync = ref.watch(selectedMonthBudgetUsageProvider);

      return usageAsync.whenData((usages) {
        return BudgetMonthSummary.fromUsages(usages);
      });
    });

final selectedMonthBudgetAttentionProvider =
    Provider<AsyncValue<BudgetAttentionSummary>>((ref) {
      final usageAsync = ref.watch(selectedMonthBudgetUsageProvider);

      return usageAsync.whenData((usages) {
        return BudgetAttentionSummary.fromUsages(usages);
      });
    });

final selectedMonthBudgetLimitProvider = Provider<double>((ref) {
  final budgets =
      ref.watch(selectedMonthBudgetsProvider).value ?? const <MonthlyBudget>[];

  return budgets.fold(0.0, (total, budget) => total + budget.limitAmount);
});

class BudgetController extends AsyncNotifier<List<MonthlyBudget>> {
  BudgetRepository get _repository => ref.read(budgetRepositoryProvider);

  @override
  Future<List<MonthlyBudget>> build() {
    final repository = ref.watch(budgetRepositoryProvider);

    return repository.getBudgets();
  }

  Future<void> addBudget(MonthlyBudget budget) async {
    await _repository.addBudget(budget);

    await _reload();
  }

  Future<void> updateBudget(MonthlyBudget budget) async {
    await _repository.updateBudget(budget);

    await _reload();
  }

  Future<void> removeBudget(String id) async {
    await _repository.deleteBudget(id);

    await _reload();
  }

  Future<void> _reload() async {
    state = AsyncData(await _repository.getBudgets());
  }
}
