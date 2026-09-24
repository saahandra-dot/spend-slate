import 'package:expense_tracker/core/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/core/utils/app_formatters.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/providers/category_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final ExpenseTransaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;

  bool _isSaving = false;

  String? _selectedCategory;
  String? _selectedAccount;

  DateTime _selectedDate = DateTime.now();

  List<String> _availableCategories(List<AppCategory> categoryOptions) {
    final categories = categoryOptions
        .map((category) => category.name)
        .toList();

    final selected = _selectedCategory;

    if (selected != null &&
        selected.isNotEmpty &&
        !categories.contains(selected)) {
      categories.add(selected);
    }

    return categories;
  }

  final List<String> _accounts = ['Debit Card', 'Credit Card', 'Savings'];

  List<String> get _availableAccounts {
    final List<String> accounts = [..._accounts];

    final selectedAccount = _selectedAccount;

    if (selectedAccount != null && !accounts.contains(selectedAccount)) {
      accounts.add(selectedAccount);
    }

    return accounts;
  }

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;
    if (transaction == null) {
      return;
    }

    _amountController.text = transaction.amount.toStringAsFixed(2);

    _selectedType = transaction.type;
    _selectedCategory = transaction.category;
    _selectedAccount = transaction.account;
    _selectedDate = transaction.date;

    _noteController.text = transaction.note ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final double amount = double.parse(_amountController.text.trim());

    final String category = _selectedCategory!;

    final String account = _selectedAccount!;

    final String note = _noteController.text.trim();

    final ExpenseTransaction? existingTransaction = widget.transaction;

    final ExpenseTransaction transaction = ExpenseTransaction(
      id:
          existingTransaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: category,
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      category: category,
      account: account,
      note: note.isEmpty ? null : note,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(transactionsProvider.notifier);

      if (existingTransaction == null) {
        await controller.addTransaction(transaction);
      } else {
        await controller.updateTransaction(transaction);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save transaction. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.transaction != null;
    final List<AppCategory> categoryOptions = ref.watch(
      categoriesForTypeProvider(_selectedType),
    );

    final List<String> availableCategories = _availableCategories(
      categoryOptions,
    );
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TransactionTypeSelector(
                  selectedType: _selectedType,
                  onChanged: (type) {
                    setState(() {
                      _selectedType = type;
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(height: 32),

                const _FieldLabel(label: 'Amount'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText: '0.00',
                    prefixStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: context.appTextPrimary,
                    ),
                  ),
                  validator: (value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    final double? amount = double.tryParse(text);
                    if (amount == null || !amount.isFinite) {
                      return 'Please enter a valid amount.';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                const _FieldLabel(label: 'Category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedType),
                  initialValue: _selectedCategory,
                  hint: const Text('Select a category'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: availableCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const _FieldLabel(label: 'Date'),
                const SizedBox(height: 8),

                _SelectionField(
                  icon: Icons.calendar_today_rounded,
                  text: AppFormatters.date(_selectedDate),
                  onTap: _selectDate,
                ),

                const SizedBox(height: 24),

                const _FieldLabel(label: 'Account'),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedAccount,
                  hint: const Text('Select an account'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: _availableAccounts.map((account) {
                    return DropdownMenuItem<String>(
                      value: account,
                      child: Text(account),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedAccount = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                const _FieldLabel(label: 'Note', optional: true),

                const SizedBox(height: 8),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add an optional note...',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 36),

                ElevatedButton(
                  onPressed: _isSaving ? null : _submitTransaction,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Transaction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const _TransactionTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Expense',
              selected: selectedType == TransactionType.expense,
              color: AppColors.expense,
              onTap: () {
                onChanged(TransactionType.expense);
              },
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Income',
              selected: selectedType == TransactionType.income,
              color: AppColors.income,
              onTap: () {
                onChanged(TransactionType.income);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? color : context.appTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool optional;

  const _FieldLabel({required this.label, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.appTextPrimary,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          Text(
            '(Optional)',
            style: TextStyle(fontSize: 12, color: context.appTextSecondary),
          ),
        ],
      ],
    );
  }
}

class _SelectionField extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SelectionField({
    required this.icon,
    required this.text,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appDivider),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.appTextSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 15, color: context.appTextPrimary),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.appTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
