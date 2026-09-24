import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_currency_scope.dart';
import 'providers/currency_provider.dart';
import 'screens/main/main_screen.dart';
import 'providers/appearance_provider.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(activeCurrencyProvider);

    final appearance = ref.watch(activeAppearanceProvider);

    return AppCurrencyScope(
      currency: currency,
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,

        darkTheme: AppTheme.darkTheme,

        themeMode: appearance.themeMode,

        home: const MainScreen(),
      ),
    );
  }
}
