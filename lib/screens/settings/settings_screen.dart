import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_currency.dart';
import '../../providers/currency_provider.dart';
import '../../core/theme/app_colors.dart';
import '../category/category_management_screen.dart';
import '../../models/app_appearance.dart';
import '../../providers/appearance_provider.dart';
import '../../core/theme/theme_context.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<AppCurrency?> _showCurrencyPicker(
    BuildContext context, {
    required AppCurrency current,
  }) {
    return showModalBottomSheet<AppCurrency>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appSurface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currency',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose how monetary values are displayed.',
                style: TextStyle(fontSize: 13, color: context.appTextSecondary),
              ),

              const SizedBox(height: 18),

              for (final currency in AppCurrency.values)
                _CurrencyOption(
                  currency: currency,
                  selected: currency == current,
                  onTap: () {
                    Navigator.of(context).pop(currency);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static Future<AppAppearance?> _showAppearancePicker(
    BuildContext context, {
    required AppAppearance current,
  }) {
    return showModalBottomSheet<AppAppearance>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose how Expense Tracker looks.',
                style: TextStyle(fontSize: 13, color: context.appTextSecondary),
              ),

              const SizedBox(height: 18),

              for (final appearance in AppAppearance.values)
                _AppearanceOption(
                  appearance: appearance,
                  selected: appearance == current,
                  onTap: () {
                    Navigator.of(context).pop(appearance);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency currency = ref.watch(activeCurrencyProvider);
    final AppAppearance appearance = ref.watch(activeAppearanceProvider);
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          children: [
            const _SettingsHeader(),

            const SizedBox(height: 30),

            const _SettingsSectionTitle(title: 'Preferences'),

            const SizedBox(height: 10),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  key: const Key('currencySettingsTile'),
                  icon: Icons.payments_outlined,
                  title: 'Currency',
                  subtitle: 'Currency used throughout the app',
                  trailing: _SettingsValue(value: currency.code),
                  onTap: () async {
                    final AppCurrency? selected = await _showCurrencyPicker(
                      context,
                      current: currency,
                    );

                    if (selected == null || selected == currency) {
                      return;
                    }

                    try {
                      await ref
                          .read(currencyProvider.notifier)
                          .setCurrency(selected);
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not save currency preference.'),
                        ),
                      );
                    }
                  },
                ),

                const _SettingsDivider(),

                _SettingsTile(
                  key: const Key('appearanceSettingsTile'),
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  subtitle: 'Choose how the app looks',
                  trailing: _SettingsValue(value: appearance.label),
                  onTap: () async {
                    final AppAppearance? selected = await _showAppearancePicker(
                      context,
                      current: appearance,
                    );

                    if (selected == null || selected == appearance) {
                      return;
                    }

                    try {
                      await ref
                          .read(appearanceProvider.notifier)
                          .setAppearance(selected);
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not save appearance preference.',
                          ),
                        ),
                      );
                    }
                  },
                ),

                const _SettingsDivider(),

                _SettingsTile(
                  key: const Key('categoriesSettingsTile'),
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  subtitle: 'Manage income and expense categories',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appTextSecondary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            const _SettingsSectionTitle(title: 'Data'),

            const SizedBox(height: 10),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  key: const Key('exportSettingsTile'),
                  icon: Icons.upload_file_outlined,
                  title: 'Export Transactions',
                  subtitle: 'Export your financial records',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appTextSecondary,
                  ),
                  onTap: () {
                    _showComingSoon(
                      context,
                      'Transaction export will be connected in Step 49.',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            const _SettingsSectionTitle(title: 'About'),

            const SizedBox(height: 10),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  key: const Key('aboutSettingsTile'),
                  icon: Icons.info_outline_rounded,
                  title: 'About Expense Tracker',
                  subtitle: 'Learn more about this app',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appTextSecondary,
                  ),
                  onTap: () {
                    _showAboutSheet(context);
                  },
                ),

                const _SettingsDivider(),

                const _SettingsTile(
                  icon: Icons.code_rounded,
                  title: 'Version',
                  subtitle: 'Current application version',
                  trailing: _SettingsValue(value: '1.0.0', showArrow: false),
                ),
              ],
            ),

            const SizedBox(height: 26),

            const _SettingsFooter(),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _showAboutSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appSurface,
      builder: (context) {
        return const _AboutSheet();
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'Manage your app preferences and data.',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: context.appTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: context.appTextSecondary,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.appSoftPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 21, color: context.appTextPrimary),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.appTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 73),
      child: Divider(height: 1, color: context.appDivider),
    );
  }
}

class _SettingsValue extends StatelessWidget {
  final String value;
  final bool showArrow;

  const _SettingsValue({required this.value, this.showArrow = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.appTextSecondary,
          ),
        ),

        if (showArrow) ...[
          const SizedBox(width: 3),

          Icon(Icons.chevron_right_rounded, color: context.appTextSecondary),
        ],
      ],
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 27,
          color: context.appTextLight,
        ),

        SizedBox(height: 8),

        Text(
          'Expense Tracker',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.appTextSecondary,
          ),
        ),

        SizedBox(height: 3),

        Text(
          'Track. Understand. Plan.',
          style: TextStyle(fontSize: 11, color: context.appTextLight),
        ),
      ],
    );
  }
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 31,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Expense Tracker',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12, color: context.appTextSecondary),
          ),

          const SizedBox(height: 20),

          Text(
            'A personal finance app for tracking transactions, understanding spending, setting goals, and managing monthly budgets.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: context.appTextSecondary,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final AppCurrency currency;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? context.appSoftPrimary
                      : context.appBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  currency.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primaryPurple
                        : context.appTextSecondary,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.appTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      currency.code,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryPurple,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final AppAppearance appearance;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.appearance,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;

    switch (appearance) {
      case AppAppearance.system:
        icon = Icons.devices_rounded;

      case AppAppearance.light:
        icon = Icons.light_mode_rounded;

      case AppAppearance.dark:
        icon = Icons.dark_mode_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? context.appSoftPrimary
                      : context.appBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : context.appTextSecondary,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  appearance.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                  ),
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
