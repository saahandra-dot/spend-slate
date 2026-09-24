import 'package:drift/drift.dart';

import '../database/app_database.dart';

class SettingsRepository {
  final AppDatabase _database;

  SettingsRepository(this._database);

  Future<String?> getValue(String key) async {
    final query = _database.select(_database.appSettingEntries)
      ..where((table) => table.key.equals(key))
      ..limit(1);

    final row = await query.getSingleOrNull();

    return row?.value;
  }

  Future<void> setValue({required String key, required String value}) async {
    await _database
        .into(_database.appSettingEntries)
        .insert(
          AppSettingEntriesCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> removeValue(String key) async {
    await (_database.delete(
      _database.appSettingEntries,
    )..where((table) => table.key.equals(key))).go();
  }
}
