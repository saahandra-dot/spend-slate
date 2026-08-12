import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/screens/home/home_screen.dart';
import 'package:expense_tracker/screens/plan/plan_screen.dart';
import 'package:expense_tracker/screens/report/report_screen.dart';
import 'package:expense_tracker/screens/settings/settings_screen.dart';
import 'package:expense_tracker/screens/transaction/add_transaction_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    ReportScreen(),
    PlanScreen(),
    SettingsScreen(),
  ];

  void _selectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        child: const Icon(
          Icons.add_rounded,
          size: 32,
        ),
      ),

      floatingActionButtonLocation: 
        FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                Expanded(
                  child: _NavigationItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _selectedPage(0),
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Report',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _selectedPage(1),
                  ),
                ),
                const SizedBox(width: 72 ), // Space for the FAB  

                Expanded(
                  child: _NavigationItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Plan',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _selectedPage(2),
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _selectedPage(3),
                  ),
                ),
              ]
          )
        )  
      )
    ));
  }
}


class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primaryPurple
        : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          )
        ]
      )
    );
  }
}