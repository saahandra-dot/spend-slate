import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/month_picker_sheet.dart';
import '../../models/transaction.dart';
import '../../providers/period_provider.dart';
import '../../providers/transaction_provider.dart';

enum _ReportType { expenses, income }

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  _ReportType _selectedType = _ReportType.expenses;

  TransactionType get _transactionType {
    switch (_selectedType) {
      case _ReportType.expenses:
        return TransactionType.expense;

      case _ReportType.income:
        return TransactionType.income;
    }
  }

  String get _reportTitle {
    switch (_selectedType) {
      case _ReportType.expenses:
        return 'Expenses Report';

      case _ReportType.income:
        return 'Income Report';
    }
  }

  String get _emptyMessage {
    switch (_selectedType) {
      case _ReportType.expenses:
        return 'No expenses recorded for this month.';

      case _ReportType.income:
        return 'No income recorded for this month.';
    }
  }

  List<ExpenseTransaction> _filterByType(
    List<ExpenseTransaction> transactions,
  ) {
    return transactions.where((transaction) {
      return transaction.type == _transactionType;
    }).toList();
  }

  List<_CategorySummary> _calculateCategorySummaries(
    List<ExpenseTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return [];
    }

    final Map<String, double> categoryTotals = {};

    final Map<String, int> categoryCounts = {};

    for (final transaction in transactions) {
      categoryTotals.update(
        transaction.category,
        (currentAmount) => currentAmount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );

      categoryCounts.update(
        transaction.category,
        (currentCount) => currentCount + 1,
        ifAbsent: () => 1,
      );
    }

    final double total = transactions.fold(
      0.0,
      (currentTotal, transaction) => currentTotal + transaction.amount,
    );

    final List<_CategorySummary> summaries = categoryTotals.entries.map((
      entry,
    ) {
      final double percentage = total == 0 ? 0 : (entry.value / total) * 100;

      return _CategorySummary(
        category: entry.key,
        amount: entry.value,
        percentage: percentage,
        transactionCount: categoryCounts[entry.key] ?? 0,
      );
    }).toList();

    summaries.sort((first, second) => second.amount.compareTo(first.amount));

    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selectedMonth = ref.watch(selectedMonthProvider);

    final transactionsAsync = ref.watch(monthlyTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _ReportHeader(),

            Expanded(
              child: transactionsAsync.when(
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, stackTrace) {
                  return _ReportErrorState(
                    onRetry: () {
                      ref.invalidate(transactionsProvider);
                    },
                  );
                },
                data: (transactions) {
                  final List<ExpenseTransaction> filteredTransactions =
                      _filterByType(transactions);

                  final double total = filteredTransactions.fold(0.0, (
                    currentTotal,
                    transaction,
                  ) {
                    return currentTotal + transaction.amount;
                  });

                  final List<_CategorySummary> categorySummaries =
                      _calculateCategorySummaries(filteredTransactions);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      children: [
                        _ReportTypeSelector(
                          selectedType: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        _MonthSelector(
                          selectedMonth: selectedMonth,
                          onTap: () async {
                            final DateTime? month = await showAppMonthPicker(
                              context: context,
                              initialMonth: selectedMonth,
                            );

                            if (!mounted || month == null) {
                              return;
                            }

                            ref
                                .read(selectedMonthProvider.notifier)
                                .setMonth(month);
                          },
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _reportTitle,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        _ReportTotalCard(
                          total: total,
                          transactionCount: filteredTransactions.length,
                          categories: categorySummaries,
                        ),

                        const SizedBox(height: 28),

                        _CategoryBreakdownSection(
                          categories: categorySummaries,
                          emptyMessage: _emptyMessage,
                          reportType: _selectedType,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Report',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ReportTypeSelector extends StatelessWidget {
  final _ReportType selectedType;

  final ValueChanged<_ReportType> onChanged;

  const _ReportTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_ReportType>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<_ReportType>(
            value: _ReportType.expenses,
            icon: Icon(Icons.arrow_upward_rounded),
            label: Text('Expenses'),
          ),
          ButtonSegment<_ReportType>(
            value: _ReportType.income,
            icon: Icon(Icons.arrow_downward_rounded),
            label: Text('Income'),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: (selection) {
          onChanged(selection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textSecondary,
          selectedBackgroundColor: AppColors.primaryPurple,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onTap;

  const _MonthSelector({required this.selectedMonth, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: AppColors.primaryPurple,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  AppFormatters.monthYear(selectedMonth),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

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

class _ReportTotalCard extends StatelessWidget {
  final double total;
  final int transactionCount;
  final List<_CategorySummary> categories;

  const _ReportTotalCard({
    required this.total,
    required this.transactionCount,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final String countText = transactionCount == 1
        ? '1 transaction'
        : '$transactionCount transactions';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _ReportDonutChart(total: total, categories: categories),

          const SizedBox(height: 18),

          _ReportChartLegend(categories: categories),

          const SizedBox(height: 22),

          const Divider(),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 17,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 7),

              Text(
                countText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportDonutChart extends StatefulWidget {
  final double total;
  final List<_CategorySummary> categories;

  const _ReportDonutChart({required this.total, required this.categories});

  @override
  State<_ReportDonutChart> createState() => _ReportDonutChartState();
}

class _ReportDonutChartState extends State<_ReportDonutChart> {
  int _touchedIndex = -1;

  @override
  void didUpdateWidget(covariant _ReportDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categories != widget.categories) {
      _touchedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return _EmptyDonutChart(total: widget.total);
    }

    final _CategorySummary? selectedCategory =
        _touchedIndex >= 0 && _touchedIndex < widget.categories.length
        ? widget.categories[_touchedIndex]
        : null;

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: _buildSections(),
              centerSpaceRadius: 72,
              sectionsSpace: 3,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;

                      return;
                    }

                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          ),

          IgnorePointer(
            child: _DonutCenterContent(
              total: widget.total,
              selectedCategory: selectedCategory,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.categories.length, (index) {
      final _CategorySummary summary = widget.categories[index];

      final bool isTouched = index == _touchedIndex;

      final Color color = _getCategoryColor(summary.category);

      return PieChartSectionData(
        value: summary.amount,
        color: color,
        radius: isTouched ? 34 : 27,
        showTitle: false,
        borderSide: isTouched
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      );
    });
  }
}

class _DonutCenterContent extends StatelessWidget {
  final double total;

  final _CategorySummary? selectedCategory;

  const _DonutCenterContent({
    required this.total,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCategory != null) {
      return SizedBox(
        width: 125,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCategory!.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              AppFormatters.currency(selectedCategory!.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${selectedCategory!.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _getCategoryColor(selectedCategory!.category),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 130,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Total',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 6),

          Text(
            AppFormatters.currency(total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDonutChart extends StatelessWidget {
  final double total;

  const _EmptyDonutChart({required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 26),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 6),

              Text(
                AppFormatters.currency(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportChartLegend extends StatelessWidget {
  final List<_CategorySummary> categories;

  const _ReportChartLegend({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<_CategorySummary> visibleCategories = categories
        .take(4)
        .toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 10,
      children: [
        for (final category in visibleCategories)
          _LegendItem(
            category: category.category,
            color: _getCategoryColor(category.category),
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String category;
  final Color color;

  const _LegendItem({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(
          category,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CategoryBreakdownSection extends StatelessWidget {
  final List<_CategorySummary> categories;

  final String emptyMessage;

  final _ReportType reportType;

  const _CategoryBreakdownSection({
    required this.categories,
    required this.emptyMessage,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            reportType == _ReportType.expenses
                ? 'Where your money went'
                : 'Where your income came from',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          if (categories.isEmpty)
            _NoReportData(message: emptyMessage)
          else
            for (int index = 0; index < categories.length; index++) ...[
              _CategoryBreakdownTile(summary: categories[index]),

              if (index != categories.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
            ],
        ],
      ),
    );
  }
}

class _CategoryBreakdownTile extends StatelessWidget {
  final _CategorySummary summary;

  const _CategoryBreakdownTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = _getCategoryColor(summary.category);

    final IconData categoryIcon = _getCategoryIcon(summary.category);

    final String countText = summary.transactionCount == 1
        ? '1 transaction'
        : '${summary.transactionCount} transactions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 21),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    countText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(summary.amount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${summary.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 13),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: summary.percentage / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
          ),
        ),
      ],
    );
  }
}

class _NoReportData extends StatelessWidget {
  final String message;

  const _NoReportData({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.lightPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primaryPurple,
                size: 28,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ReportErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.expense,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load report',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your transaction data could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 18),

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

class _CategorySummary {
  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;

  const _CategorySummary({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'groceries':
      return AppColors.green;

    case 'cafe':
    case 'cafes':
      return AppColors.orange;

    case 'clothing':
      return AppColors.primaryPurple;

    case 'transport':
      return AppColors.blue;

    case 'entertainment':
      return AppColors.primaryPurple;

    case 'health':
      return AppColors.expense;

    case 'education':
      return AppColors.blue;

    case 'bills':
      return AppColors.orange;

    case 'salary':
      return AppColors.positive;

    case 'freelance':
      return AppColors.blue;

    case 'business':
      return AppColors.primaryPurple;

    case 'investment':
      return AppColors.positive;

    case 'gift':
      return AppColors.orange;

    case 'other income':
      return AppColors.textSecondary;

    default:
      return AppColors.primaryPurple;
  }
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'groceries':
      return Icons.shopping_basket_rounded;

    case 'cafe':
    case 'cafes':
      return Icons.local_cafe_rounded;

    case 'clothing':
      return Icons.checkroom_rounded;

    case 'transport':
      return Icons.directions_car_rounded;

    case 'entertainment':
      return Icons.movie_rounded;

    case 'health':
      return Icons.favorite_rounded;

    case 'education':
      return Icons.school_rounded;

    case 'bills':
      return Icons.receipt_long_rounded;

    case 'salary':
      return Icons.payments_rounded;

    case 'freelance':
      return Icons.work_rounded;

    case 'business':
      return Icons.business_center_rounded;

    case 'investment':
      return Icons.trending_up_rounded;

    case 'gift':
      return Icons.card_giftcard_rounded;

    case 'other income':
      return Icons.attach_money_rounded;

    default:
      return Icons.category_rounded;
  }
}
