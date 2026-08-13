import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;

  String? _selectedCategory;
  String? _selectedAccount;

  DateTime _selectedDate = DateTime.now();

  final List<String> _expensecCategories = [
    'Groceries',
    'Cafe',
    'Clothing',
    'Transport',
    'Entertainment',
    'Health',
    'Education',
    'Bills',
    'Salary',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other Income',
  ];

  final List<String> _accounts = ['Debit Card', 'Credit Card', 'Savings'];

  List<String> get _availableCategories {
    if (_selectedType == TransactionType.income) {
      return _incomeCategories;
    }
    return _expensecCategories;
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

  void _submitTransaction() {
    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final double amount = double.parse(_amountController.text.trim());

    debugPrint('Transaction type: $_selectedType');

    debugPrint('Amount: $amount');

    debugPrint('Category: $_selectedCategory');

    debugPrint('Date: $_selectedDate');

    debugPrint('Account: $_selectedAccount');

    debugPrint('Note: ${_noteController.text.trim()}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction is valid.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText: '0.00',
                    prefixStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                  items: _availableCategories.map((category) {
                    return DropdownMenuItem<String>(
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
                  text: _formatDate(_selectedDate),
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
                  items: _accounts.map((account) {
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
                  onPressed: _submitTransaction,
                  child: const Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
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
                color: selected ? color : AppColors.textSecondary,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          const Text(
            '(Optional)',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
