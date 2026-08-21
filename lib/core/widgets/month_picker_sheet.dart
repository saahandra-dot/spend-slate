import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_formatters.dart';

Future<DateTime?> showAppMonthPicker({
  required BuildContext context,
  required DateTime initialMonth,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return _MonthPickerSheet(initialMonth: initialMonth);
    },
  );
}

class _MonthPickerSheet extends StatefulWidget {
  final DateTime initialMonth;

  const _MonthPickerSheet({required this.initialMonth});

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();

    _selectedYear = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedYear--;
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),

              Expanded(
                child: Text(
                  '$_selectedYear',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedYear++;
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final int month = index + 1;

              final DateTime date = DateTime(_selectedYear, month);

              final bool selected =
                  widget.initialMonth.year == _selectedYear &&
                  widget.initialMonth.month == month;

              return Material(
                color: selected
                    ? AppColors.primaryPurple
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).pop(date);
                  },
                  child: Center(
                    child: Text(
                      AppFormatters.shortMonth(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
