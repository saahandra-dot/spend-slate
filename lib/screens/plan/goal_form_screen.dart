import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/goal_visuals.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  final SavingsGoal? goal;

  const GoalFormScreen({super.key, this.goal});

  bool get isEditing => goal != null;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _targetAmountController;

  late final TextEditingController _currentAmountController;

  DateTime? _targetDate;

  GoalIconKey _iconKey = GoalIconKey.savings;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final SavingsGoal? goal = widget.goal;

    _nameController = TextEditingController(text: goal?.name ?? '');

    _targetAmountController = TextEditingController(
      text: goal == null ? '' : _amountText(goal.targetAmount),
    );

    _currentAmountController = TextEditingController(
      text: goal == null ? '0' : _amountText(goal.currentAmount),
    );

    _targetDate = goal?.targetDate;

    _iconKey = goal?.iconKey ?? GoalIconKey.savings;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();

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

  Future<void> _pickTargetDate() async {
    final DateTime now = DateTime.now();

    final DateTime initialDate =
        _targetDate ?? DateTime(now.year, now.month + 1, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 20),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _targetDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double targetAmount = _parseAmount(_targetAmountController.text)!;

    final double currentAmount = _parseAmount(_currentAmountController.text)!;

    final SavingsGoal? existing = widget.goal;

    final SavingsGoal goal = SavingsGoal(
      id: existing?.id ?? 'goal-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: _targetDate,
      iconKey: _iconKey,
      createdAt: existing?.createdAt ?? DateTime.now(),
      isCompleted: currentAmount >= targetAmount,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(goalsProvider.notifier);

      if (existing == null) {
        await controller.addGoal(goal);
      } else {
        await controller.updateGoal(goal);
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
        const SnackBar(content: Text('Could not save goal. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Goal' : 'Add Goal',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            key: const Key('goalFormListView'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _GoalPreview(
                iconKey: _iconKey,
                name: _nameController.text.trim().isEmpty
                    ? 'Your Goal'
                    : _nameController.text.trim(),
              ),

              const SizedBox(height: 28),

              TextFormField(
                key: const Key('goalNameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Goal name',
                  hintText: 'e.g. Vacation',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                onChanged: (_) {
                  setState(() {});
                },
                validator: (value) {
                  final String name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter a goal name';
                  }

                  if (name.length > 40) {
                    return 'Use 40 characters or fewer';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                key: const Key('goalTargetAmountField'),
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target amount',
                  hintText: '10000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final double? amount = _parseAmount(value ?? '');

                  if (amount == null) {
                    return 'Enter a valid target amount';
                  }

                  if (!amount.isFinite || amount <= 0) {
                    return 'Target amount must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                key: const Key('goalCurrentAmountField'),
                controller: _currentAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Already saved',
                  hintText: '0',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
                validator: (value) {
                  final double? amount = _parseAmount(value ?? '');

                  if (amount == null) {
                    return 'Enter a valid saved amount';
                  }

                  if (!amount.isFinite || amount < 0) {
                    return 'Saved amount cannot be negative';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _TargetDateField(
                targetDate: _targetDate,
                onTap: _pickTargetDate,
                onClear: _targetDate == null
                    ? null
                    : () {
                        setState(() {
                          _targetDate = null;
                        });
                      },
              ),

              const SizedBox(height: 28),

              const Text(
                'Goal Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final iconKey in GoalIconKey.values)
                    ChoiceChip(
                      avatar: Icon(iconKey.iconData, size: 18),
                      label: Text(iconKey.label),
                      selected: _iconKey == iconKey,
                      onSelected: (_) {
                        setState(() {
                          _iconKey = iconKey;
                        });
                      },
                    ),
                ],
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('saveGoalButton'),
                  onPressed: _isSaving ? null : _saveGoal,
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
                        : 'Create Goal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalPreview extends StatelessWidget {
  final GoalIconKey iconKey;
  final String name;

  const _GoalPreview({required this.iconKey, required this.name});

  @override
  Widget build(BuildContext context) {
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
            child: Icon(iconKey.iconData, color: Colors.white, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Goal',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),

                const SizedBox(height: 4),

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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

class _TargetDateField extends StatelessWidget {
  final DateTime? targetDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _TargetDateField({
    required this.targetDate,
    required this.onTap,
    required this.onClear,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_outlined, color: AppColors.primaryPurple),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target date',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      targetDate == null
                          ? 'No target date'
                          : AppFormatters.date(targetDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              if (onClear != null)
                IconButton(
                  tooltip: 'Remove target date',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                )
              else
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
