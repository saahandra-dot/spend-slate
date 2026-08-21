import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/month_picker_sheet.dart';
import '../../../providers/period_provider.dart';
import '../../../providers/transaction_provider.dart';
import 'money_summary_card.dart';

class BalanceHeader extends ConsumerWidget {
  const BalanceHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // All-time balance.
    final double currentBalance = ref.watch(currentBalanceProvider);

    // Shared month used by Home + Report.
    final DateTime selectedMonth = ref.watch(selectedMonthProvider);

    // Monthly values.
    final double income = ref.watch(monthlyIncomeProvider);

    final double expenses = ref.watch(monthlyExpensesProvider);

    return SizedBox(
      height: 455,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 330,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _ProfileAvatar(),

                        const Spacer(),

                        _MonthSelector(
                          selectedMonth: selectedMonth,
                          onTap: () async {
                            final DateTime? month = await showAppMonthPicker(
                              context: context,
                              initialMonth: selectedMonth,
                            );

                            if (month == null) {
                              return;
                            }

                            ref
                                .read(selectedMonthProvider.notifier)
                                .setMonth(month);
                          },
                        ),

                        const SizedBox(width: 8),

                        const _NotificationButton(),
                      ],
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppFormatters.currency(currentBalance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Colors.white70,
                        ),

                        const SizedBox(width: 6),

                        const Expanded(
                          child: Text(
                            'Based on your recorded transactions',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 270,
            left: 20,
            right: 20,
            child: MoneySummaryCard(income: income, expenses: expenses),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 23),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No new notifications.')),
          );
        },
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.notifications_none_rounded,
            size: 21,
            color: Colors.white,
          ),
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
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                AppFormatters.monthYear(selectedMonth),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 3),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
