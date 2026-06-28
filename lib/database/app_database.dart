import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('BookData')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().nullable().unique()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get isbn => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('owned'))();
  TextColumn get review => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get location => text().nullable()();
  BoolColumn get priorityRead =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get medium => text().withDefault(const Constant('paper'))();
  TextColumn get language => text().nullable()();
  TextColumn get callNumber => text().nullable()();
  TextColumn get kdc => text().nullable()();
  TextColumn get ddc => text().nullable()();
  TextColumn get lc  => text().nullable()();
  DateTimeColumn get acquiredAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// 오프라인 동기화 큐. operation: 'insert' | 'update' | 'delete'.
/// payload: snake_case JSON 스냅샷 (delete는 식별자만).
@DataClassName('SyncQueueData')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get localBookId => integer()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Books, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.alterTable(TableMigration(books));
          }
          if (from < 3) {
            await m.createTable(syncQueue);
          }
          if (from < 4) {
            await m.addColumn(books, books.isRead);
            await m.addColumn(books, books.medium);
            await m.addColumn(books, books.language);
            await m.addColumn(books, books.callNumber);
          }
          if (from < 5) {
            await m.addColumn(books, books.acquiredAt);
          }
          if (from < 6) {
            await m.addColumn(books, books.kdc);
            await m.addColumn(books, books.ddc);
            await m.addColumn(books, books.lc);
          }
        },
      );
}

QueryExecutor openDatabaseConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mylibrary.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
