import 'package:expense_tracker/providers/period_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'transaction_details_screen.dart';

enum _TransactionTypeFilter { all, expense, income }

enum _TransactionSortOption { newest, oldest, highestAmount, lowestAmount }

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  _TransactionTypeFilter _typeFilter = _TransactionTypeFilter.all;

  String? _selectedCategory;

  _TransactionSortOption _sortOption = _TransactionSortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _typeFilter != _TransactionTypeFilter.all ||
        _selectedCategory != null ||
        _sortOption != _TransactionSortOption.newest;
  }

  void _clearFilters() {
    setState(() {
      _typeFilter = _TransactionTypeFilter.all;

      _selectedCategory = null;

      _sortOption = _TransactionSortOption.newest;
    });
  }

  void _resetSearchAndFilters() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';

      _typeFilter = _TransactionTypeFilter.all;

      _selectedCategory = null;

      _sortOption = _TransactionSortOption.newest;
    });
  }

  List<ExpenseTransaction> _filterTransactions(
    List<ExpenseTransaction> transactions,
  ) {
    final String query = _searchQuery.trim().toLowerCase();

    return transactions.where((transaction) {
      final String title = transaction.title.toLowerCase();

      final String category = transaction.category.toLowerCase();

      final String account = transaction.account?.toLowerCase() ?? '';

      final String note = transaction.note?.toLowerCase() ?? '';

      final bool matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          category.contains(query) ||
          account.contains(query) ||
          note.contains(query);

      final bool matchesType = switch (_typeFilter) {
        _TransactionTypeFilter.all => true,

        _TransactionTypeFilter.expense =>
          transaction.type == TransactionType.expense,

        _TransactionTypeFilter.income =>
          transaction.type == TransactionType.income,
      };

      final bool matchesCategory =
          _selectedCategory == null ||
          transaction.category == _selectedCategory;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  List<_TransactionGroup> _groupTransactions(
    List<ExpenseTransaction> transactions,
  ) {
    final Map<DateTime, List<ExpenseTransaction>> groupedTransactions = {};

    for (final transaction in transactions) {
      final DateTime date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      groupedTransactions.putIfAbsent(date, () => []);

      groupedTransactions[date]!.add(transaction);
    }

    final List<DateTime> dates = groupedTransactions.keys.toList();

    if (_sortOption == _TransactionSortOption.oldest) {
      dates.sort((first, second) => first.compareTo(second));
    } else {
      dates.sort((first, second) => second.compareTo(first));
    }

    for (final date in dates) {
      final List<ExpenseTransaction> group = groupedTransactions[date]!;

      switch (_sortOption) {
        case _TransactionSortOption.newest:
          group.sort((first, second) => second.date.compareTo(first.date));

        case _TransactionSortOption.oldest:
          group.sort((first, second) => first.date.compareTo(second.date));

        case _TransactionSortOption.highestAmount:
          group.sort((first, second) => second.amount.compareTo(first.amount));

        case _TransactionSortOption.lowestAmount:
          group.sort((first, second) => first.amount.compareTo(second.amount));
      }
    }

    return dates.map((date) {
      return _TransactionGroup(
        date: date,
        transactions: groupedTransactions[date]!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All Transactions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: transactionsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _ErrorState(
            onRetry: () {
              ref.invalidate(monthlyTransactionsProvider);
            },
          );
        },
        data: (transactions) {
          if (transactions.isEmpty) {
            return _EmptyState(
              onAddTransaction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
            );
          }

          final List<String> categories =
              transactions
                  .map((transaction) => transaction.category)
                  .toSet()
                  .toList()
                ..sort();

          final List<ExpenseTransaction> filteredTransactions =
              _filterTransactions(transactions);

          final double filteredIncome = filteredTransactions
              .where(
                (transaction) => transaction.type == TransactionType.income,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          final double filteredExpenses = filteredTransactions
              .where(
                (transaction) => transaction.type == TransactionType.expense,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          final List<_TransactionGroup> groups = _groupTransactions(
            filteredTransactions,
          );

          return Column(
            children: [
              _TransactionsOverview(
                transactionCount: filteredTransactions.length,
                totalIncome: filteredIncome,
                totalExpenses: filteredExpenses,
              ),

              _TransactionSearchField(
                controller: _searchController,
                query: _searchQuery,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              _TransactionTypeFilters(
                selected: _typeFilter,
                onChanged: (value) {
                  setState(() {
                    _typeFilter = value;
                  });
                },
              ),

              _FilterOptions(
                categories: categories,
                selectedCategory: _selectedCategory,
                sortOption: _sortOption,
                onCategoryChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                onSortChanged: (value) {
                  setState(() {
                    _sortOption = value;
                  });
                },
              ),

              if (_hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                      label: const Text('Clear Filters'),
                    ),
                  ),
                ),

              Expanded(
                child: filteredTransactions.isEmpty
                    ? _NoSearchResults(
                        query: _searchQuery,
                        onReset: _resetSearchAndFilters,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];

                          return _TransactionDateSection(
                            date: group.date,
                            transactions: group.transactions,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionsOverview extends StatelessWidget {
  final int transactionCount;
  final double totalIncome;
  final double totalExpenses;

  const _TransactionsOverview({
    required this.transactionCount,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final String countText = transactionCount == 1
        ? '1 transaction'
        : '$transactionCount transactions';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            countText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _OverviewItem(
                  label: 'Income',
                  amount: AppFormatters.currency(totalIncome),
                  color: AppColors.positive,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),

              const SizedBox(width: 16),

              const SizedBox(
                height: 52,
                child: VerticalDivider(width: 1, color: AppColors.divider),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _OverviewItem(
                  label: 'Expenses',
                  amount: AppFormatters.currency(totalExpenses),
                  color: AppColors.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _OverviewItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: color),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _TransactionSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        key: const Key('transactionSearchField'),
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
        ),
      ),
    );
  }
}

class _TransactionTypeFilters extends StatelessWidget {
  final _TransactionTypeFilter selected;

  final ValueChanged<_TransactionTypeFilter> onChanged;

  const _TransactionTypeFilters({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const SizedBox(
                width: double.infinity,
                child: Text('All', textAlign: TextAlign.center),
              ),
              selected: selected == _TransactionTypeFilter.all,
              onSelected: (_) {
                onChanged(_TransactionTypeFilter.all);
              },
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: ChoiceChip(
              label: const SizedBox(
                width: double.infinity,
                child: Text('Expense', textAlign: TextAlign.center),
              ),
              selected: selected == _TransactionTypeFilter.expense,
              onSelected: (_) {
                onChanged(_TransactionTypeFilter.expense);
              },
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: ChoiceChip(
              label: const SizedBox(
                width: double.infinity,
                child: Text('Income', textAlign: TextAlign.center),
              ),
              selected: selected == _TransactionTypeFilter.income,
              onSelected: (_) {
                onChanged(_TransactionTypeFilter.income);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptions extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;

  final _TransactionSortOption sortOption;

  final ValueChanged<String?> onCategoryChanged;

  final ValueChanged<_TransactionSortOption> onSortChanged;

  const _FilterOptions({
    required this.categories,
    required this.selectedCategory,
    required this.sortOption,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          DropdownButtonFormField<String?>(
            key: ValueKey('category-$selectedCategory'),
            initialValue: selectedCategory,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map((category) {
                return DropdownMenuItem<String?>(
                  value: category,
                  child: Text(category, overflow: TextOverflow.ellipsis),
                );
              }),
            ],
            onChanged: onCategoryChanged,
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<_TransactionSortOption>(
            key: ValueKey('sort-$sortOption'),
            initialValue: sortOption,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Sort By',
              prefixIcon: Icon(Icons.swap_vert_rounded),
            ),
            items: const [
              DropdownMenuItem(
                value: _TransactionSortOption.newest,
                child: Text('Newest First'),
              ),
              DropdownMenuItem(
                value: _TransactionSortOption.oldest,
                child: Text('Oldest First'),
              ),
              DropdownMenuItem(
                value: _TransactionSortOption.highestAmount,
                child: Text('Highest Amount'),
              ),
              DropdownMenuItem(
                value: _TransactionSortOption.lowestAmount,
                child: Text('Lowest Amount'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              onSortChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String query;
  final VoidCallback onReset;

  const _NoSearchResults({required this.query, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final String message = query.trim().isEmpty
        ? 'No transactions match the selected filters.'
        : 'No transactions match your search and selected filters.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.lightPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: AppColors.primaryPurple,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No matching transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Search & Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDateSection extends StatelessWidget {
  final DateTime date;

  final List<ExpenseTransaction> transactions;

  const _TransactionDateSection({
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final double income = transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (total, transaction) => total + transaction.amount);

    final double expenses = transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (total, transaction) => total + transaction.amount);

    final double net = income - expenses;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateHeader(date: date, net: net),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                for (int index = 0; index < transactions.length; index++) ...[
                  TransactionTile(
                    transaction: transactions[index],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailsScreen(
                            transaction: transactions[index],
                          ),
                        ),
                      );
                    },
                  ),

                  if (index != transactions.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final double net;

  const _DateHeader({required this.date, required this.net});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = net >= 0;

    final String formattedNet =
        '${isPositive ? '+' : '-'}'
        '${AppFormatters.currency(net.abs())}';

    return Row(
      children: [
        Expanded(
          child: Text(
            AppFormatters.transactionGroupDate(date),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const Text(
          'Net ',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        Text(
          formattedNet,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.positive : AppColors.expense,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const _EmptyState({required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.lightPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 34,
                color: AppColors.primaryPurple,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your income and expenses '
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onAddTransaction,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

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
              color: AppColors.expense,
              size: 42,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please try loading your '
              'transaction history again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),

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

class _TransactionGroup {
  final DateTime date;

  final List<ExpenseTransaction> transactions;

  const _TransactionGroup({required this.date, required this.transactions});
}
