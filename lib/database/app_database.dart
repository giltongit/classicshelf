import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Supabase books 스키마와 1:1 대응.
/// id: 로컬 auto-increment PK (Drift 내부용)
/// supabaseId: Supabase uuid, unique index (비즈니스 식별자)
/// @DataClassName: 도메인 모델 Book과 이름 충돌 방지 → BookData
@DataClassName('BookData')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().unique()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get isbn => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('owned'))();
  TextColumn get review => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get location => text().nullable()();
  BoolColumn get priorityRead =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

QueryExecutor openDatabaseConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mylibrary.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
