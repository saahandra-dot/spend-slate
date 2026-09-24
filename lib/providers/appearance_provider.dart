import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_appearance.dart';
import '../repositories/settings_repository.dart';
import 'settings_provider.dart';

const String _appearanceSettingKey = 'appearance';

final appearanceProvider =
    AsyncNotifierProvider<AppearanceController, AppAppearance>(
      AppearanceController.new,
    );

final activeAppearanceProvider = Provider<AppAppearance>((ref) {
  return ref.watch(appearanceProvider).value ?? AppAppearance.system;
});

class AppearanceController extends AsyncNotifier<AppAppearance> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  Future<AppAppearance> build() async {
    final repository = ref.watch(settingsRepositoryProvider);

    final String? savedValue = await repository.getValue(_appearanceSettingKey);

    return AppAppearance.fromValue(savedValue);
  }

  Future<void> setAppearance(AppAppearance appearance) async {
    final previousState = state;

    // Update the UI immediately.
    state = AsyncData(appearance);

    try {
      await _repository.setValue(
        key: _appearanceSettingKey,
        value: appearance.value,
      );
    } catch (error, stackTrace) {
      state = previousState;

      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
