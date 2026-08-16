import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class TransactionEntries extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  TextColumn get account => text().nullable()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TransactionEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults() : super(driftDatabase(name: 'expense_tracker'));

  @override
  int get schemaVersion => 1;
}
