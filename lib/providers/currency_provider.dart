import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_currency.dart';
import '../repositories/settings_repository.dart';
import 'transaction_provider.dart';
import 'settings_provider.dart';

const String _currencySettingKey = 'currency';

final currencyProvider = AsyncNotifierProvider<CurrencyController, AppCurrency>(
  CurrencyController.new,
);

final activeCurrencyProvider = Provider<AppCurrency>((ref) {
  return ref.watch(currencyProvider).value ?? AppCurrency.usd;
});

class CurrencyController extends AsyncNotifier<AppCurrency> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  Future<AppCurrency> build() async {
    final repository = ref.watch(settingsRepositoryProvider);

    final String? savedCode = await repository.getValue(_currencySettingKey);

    return AppCurrency.fromCode(savedCode);
  }

  Future<void> setCurrency(AppCurrency currency) async {
    final previousState = state;

    // Change UI immediately.
    state = AsyncData(currency);

    try {
      await _repository.setValue(
        key: _currencySettingKey,
        value: currency.code,
      );
    } catch (error, stackTrace) {
      state = previousState;

      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
