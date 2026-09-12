import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/category_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/month_picker_sheet.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../repositories/budget_repository.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  final MonthlyBudget? budget;
  final DateTime initialMonth;

  const BudgetFormScreen({super.key, this.budget, required this.initialMonth});

  bool get isEditing => budget != null;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _limitController;

  String? _selectedCategoryId;
  late DateTime _selectedMonth;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final MonthlyBudget? budget = widget.budget;

    _selectedCategoryId = budget?.categoryId;

    _selectedMonth = DateTime(
      budget?.month.year ?? widget.initialMonth.year,
      budget?.month.month ?? widget.initialMonth.month,
    );

    _limitController = TextEditingController(
      text: budget == null ? '' : _amountText(budget.limitAmount),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  String _amountText(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  double? _parseAmount(String value) {
    return double.tryParse(value.trim().replaceAll(',', ''));
  }

  Future<void> _pickMonth() async {
    final DateTime? month = await showAppMonthPicker(
      context: context,
      initialMonth: _selectedMonth,
    );

    if (month == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(month.year, month.month);
    });
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? categoryId = _selectedCategoryId;

    if (categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose a category.')));

      return;
    }

    final double limitAmount = _parseAmount(_limitController.text)!;

    final MonthlyBudget? existing = widget.budget;

    final MonthlyBudget budget = MonthlyBudget(
      id: existing?.id ?? 'budget-${DateTime.now().microsecondsSinceEpoch}',
      categoryId: categoryId,
      limitAmount: limitAmount,
      month: DateTime(_selectedMonth.year, _selectedMonth.month),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(budgetsProvider.notifier);

      if (existing == null) {
        await controller.addBudget(budget);
      } else {
        await controller.updateBudget(budget);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on BudgetOperationException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save budget. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Budget' : 'Add Budget',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _CategoryLoadError(
            onRetry: () {
              ref.invalidate(categoriesProvider);
            },
          ),
          data: (categories) {
            final List<AppCategory> expenseCategories = categories
                .where((category) => category.type == TransactionType.expense)
                .toList();

            final AppCategory? selectedCategory = _selectedCategoryId == null
                ? null
                : CategoryCatalog.findById(
                    expenseCategories,
                    _selectedCategoryId!,
                  );

            return Form(
              key: _formKey,
              child: ListView(
                key: const Key('budgetFormList'),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  _BudgetPreview(
                    category: selectedCategory,
                    month: _selectedMonth,
                  ),

                  const SizedBox(height: 28),

                  DropdownButtonFormField<String>(
                    key: const Key('budgetCategoryField'),
                    initialValue: selectedCategory?.id,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: expenseCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(
                              category.iconKey.iconData,
                              size: 20,
                              color: category.colorKey.color,
                            ),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Choose a category';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    key: const Key('budgetLimitField'),
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monthly limit',
                      hintText: '5000',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final double? amount = _parseAmount(value ?? '');

                      if (amount == null) {
                        return 'Enter a valid budget limit';
                      }

                      if (!amount.isFinite || amount <= 0) {
                        return 'Budget limit must be greater than 0';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _BudgetMonthField(
                    month: _selectedMonth,
                    onTap: _isSaving ? null : _pickMonth,
                  ),

                  const SizedBox(height: 34),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('saveBudgetButton'),
                      onPressed: _isSaving ? null : _saveBudget,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              widget.isEditing
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                            ),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : widget.isEditing
                            ? 'Save Changes'
                            : 'Create Budget',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BudgetPreview extends StatelessWidget {
  final AppCategory? category;
  final DateTime month;

  const _BudgetPreview({required this.category, required this.month});

  @override
  Widget build(BuildContext context) {
    final Color color = category?.colorKey.color ?? AppColors.primaryPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              category?.iconKey.iconData ??
                  Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppFormatters.monthYear(month),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),

                const SizedBox(height: 4),

                Text(
                  category?.name ?? 'Monthly Budget',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category == null
                      ? 'Choose an expense category'
                      : 'Spending limit',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetMonthField extends StatelessWidget {
  final DateTime month;
  final VoidCallback? onTap;

  const _BudgetMonthField({required this.month, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primaryPurple,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Budget month',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              Text(
                AppFormatters.monthYear(month),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 4),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CategoryLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.expense,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load categories',
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
      ),
    );
  }
}
