// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorksTable extends Works with TableInfo<$WorksTable, WorkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _composerMeta = const VerificationMeta(
    'composer',
  );
  @override
  late final GeneratedColumn<String> composer = GeneratedColumn<String>(
    'composer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogNumberMeta = const VerificationMeta(
    'catalogNumber',
  );
  @override
  late final GeneratedColumn<String> catalogNumber = GeneratedColumn<String>(
    'catalog_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _musicalKeyMeta = const VerificationMeta(
    'musicalKey',
  );
  @override
  late final GeneratedColumn<String> musicalKey = GeneratedColumn<String>(
    'musical_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _popularMeta = const VerificationMeta(
    'popular',
  );
  @override
  late final GeneratedColumn<bool> popular = GeneratedColumn<bool>(
    'popular',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("popular" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recommendedMeta = const VerificationMeta(
    'recommended',
  );
  @override
  late final GeneratedColumn<bool> recommended = GeneratedColumn<bool>(
    'recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recommended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('openopus'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    composer,
    title,
    catalogNumber,
    musicalKey,
    genre,
    period,
    popular,
    recommended,
    source,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'works';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('composer')) {
      context.handle(
        _composerMeta,
        composer.isAcceptableOrUnknown(data['composer']!, _composerMeta),
      );
    } else if (isInserting) {
      context.missing(_composerMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('catalog_number')) {
      context.handle(
        _catalogNumberMeta,
        catalogNumber.isAcceptableOrUnknown(
          data['catalog_number']!,
          _catalogNumberMeta,
        ),
      );
    }
    if (data.containsKey('musical_key')) {
      context.handle(
        _musicalKeyMeta,
        musicalKey.isAcceptableOrUnknown(data['musical_key']!, _musicalKeyMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('popular')) {
      context.handle(
        _popularMeta,
        popular.isAcceptableOrUnknown(data['popular']!, _popularMeta),
      );
    }
    if (data.containsKey('recommended')) {
      context.handle(
        _recommendedMeta,
        recommended.isAcceptableOrUnknown(
          data['recommended']!,
          _recommendedMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      composer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composer'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      catalogNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_number'],
      ),
      musicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}musical_key'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      ),
      popular: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}popular'],
      )!,
      recommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recommended'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $WorksTable createAlias(String alias) {
    return $WorksTable(attachedDatabase, alias);
  }
}

class WorkData extends DataClass implements Insertable<WorkData> {
  final String id;
  final String composer;
  final String title;
  final String? catalogNumber;
  final String? musicalKey;
  final String? genre;
  final String? period;
  final bool popular;
  final bool recommended;
  final String source;
  final DateTime cachedAt;
  const WorkData({
    required this.id,
    required this.composer,
    required this.title,
    this.catalogNumber,
    this.musicalKey,
    this.genre,
    this.period,
    required this.popular,
    required this.recommended,
    required this.source,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['composer'] = Variable<String>(composer);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || catalogNumber != null) {
      map['catalog_number'] = Variable<String>(catalogNumber);
    }
    if (!nullToAbsent || musicalKey != null) {
      map['musical_key'] = Variable<String>(musicalKey);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    map['popular'] = Variable<bool>(popular);
    map['recommended'] = Variable<bool>(recommended);
    map['source'] = Variable<String>(source);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  WorksCompanion toCompanion(bool nullToAbsent) {
    return WorksCompanion(
      id: Value(id),
      composer: Value(composer),
      title: Value(title),
      catalogNumber: catalogNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogNumber),
      musicalKey: musicalKey == null && nullToAbsent
          ? const Value.absent()
          : Value(musicalKey),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      period: period == null && nullToAbsent
          ? const Value.absent()
          : Value(period),
      popular: Value(popular),
      recommended: Value(recommended),
      source: Value(source),
      cachedAt: Value(cachedAt),
    );
  }

  factory WorkData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkData(
      id: serializer.fromJson<String>(json['id']),
      composer: serializer.fromJson<String>(json['composer']),
      title: serializer.fromJson<String>(json['title']),
      catalogNumber: serializer.fromJson<String?>(json['catalogNumber']),
      musicalKey: serializer.fromJson<String?>(json['musicalKey']),
      genre: serializer.fromJson<String?>(json['genre']),
      period: serializer.fromJson<String?>(json['period']),
      popular: serializer.fromJson<bool>(json['popular']),
      recommended: serializer.fromJson<bool>(json['recommended']),
      source: serializer.fromJson<String>(json['source']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'composer': serializer.toJson<String>(composer),
      'title': serializer.toJson<String>(title),
      'catalogNumber': serializer.toJson<String?>(catalogNumber),
      'musicalKey': serializer.toJson<String?>(musicalKey),
      'genre': serializer.toJson<String?>(genre),
      'period': serializer.toJson<String?>(period),
      'popular': serializer.toJson<bool>(popular),
      'recommended': serializer.toJson<bool>(recommended),
      'source': serializer.toJson<String>(source),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  WorkData copyWith({
    String? id,
    String? composer,
    String? title,
    Value<String?> catalogNumber = const Value.absent(),
    Value<String?> musicalKey = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> period = const Value.absent(),
    bool? popular,
    bool? recommended,
    String? source,
    DateTime? cachedAt,
  }) => WorkData(
    id: id ?? this.id,
    composer: composer ?? this.composer,
    title: title ?? this.title,
    catalogNumber: catalogNumber.present
        ? catalogNumber.value
        : this.catalogNumber,
    musicalKey: musicalKey.present ? musicalKey.value : this.musicalKey,
    genre: genre.present ? genre.value : this.genre,
    period: period.present ? period.value : this.period,
    popular: popular ?? this.popular,
    recommended: recommended ?? this.recommended,
    source: source ?? this.source,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  WorkData copyWithCompanion(WorksCompanion data) {
    return WorkData(
      id: data.id.present ? data.id.value : this.id,
      composer: data.composer.present ? data.composer.value : this.composer,
      title: data.title.present ? data.title.value : this.title,
      catalogNumber: data.catalogNumber.present
          ? data.catalogNumber.value
          : this.catalogNumber,
      musicalKey: data.musicalKey.present
          ? data.musicalKey.value
          : this.musicalKey,
      genre: data.genre.present ? data.genre.value : this.genre,
      period: data.period.present ? data.period.value : this.period,
      popular: data.popular.present ? data.popular.value : this.popular,
      recommended: data.recommended.present
          ? data.recommended.value
          : this.recommended,
      source: data.source.present ? data.source.value : this.source,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkData(')
          ..write('id: $id, ')
          ..write('composer: $composer, ')
          ..write('title: $title, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('genre: $genre, ')
          ..write('period: $period, ')
          ..write('popular: $popular, ')
          ..write('recommended: $recommended, ')
          ..write('source: $source, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    composer,
    title,
    catalogNumber,
    musicalKey,
    genre,
    period,
    popular,
    recommended,
    source,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkData &&
          other.id == this.id &&
          other.composer == this.composer &&
          other.title == this.title &&
          other.catalogNumber == this.catalogNumber &&
          other.musicalKey == this.musicalKey &&
          other.genre == this.genre &&
          other.period == this.period &&
          other.popular == this.popular &&
          other.recommended == this.recommended &&
          other.source == this.source &&
          other.cachedAt == this.cachedAt);
}

class WorksCompanion extends UpdateCompanion<WorkData> {
  final Value<String> id;
  final Value<String> composer;
  final Value<String> title;
  final Value<String?> catalogNumber;
  final Value<String?> musicalKey;
  final Value<String?> genre;
  final Value<String?> period;
  final Value<bool> popular;
  final Value<bool> recommended;
  final Value<String> source;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const WorksCompanion({
    this.id = const Value.absent(),
    this.composer = const Value.absent(),
    this.title = const Value.absent(),
    this.catalogNumber = const Value.absent(),
    this.musicalKey = const Value.absent(),
    this.genre = const Value.absent(),
    this.period = const Value.absent(),
    this.popular = const Value.absent(),
    this.recommended = const Value.absent(),
    this.source = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorksCompanion.insert({
    required String id,
    required String composer,
    required String title,
    this.catalogNumber = const Value.absent(),
    this.musicalKey = const Value.absent(),
    this.genre = const Value.absent(),
    this.period = const Value.absent(),
    this.popular = const Value.absent(),
    this.recommended = const Value.absent(),
    this.source = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       composer = Value(composer),
       title = Value(title);
  static Insertable<WorkData> custom({
    Expression<String>? id,
    Expression<String>? composer,
    Expression<String>? title,
    Expression<String>? catalogNumber,
    Expression<String>? musicalKey,
    Expression<String>? genre,
    Expression<String>? period,
    Expression<bool>? popular,
    Expression<bool>? recommended,
    Expression<String>? source,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (composer != null) 'composer': composer,
      if (title != null) 'title': title,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (musicalKey != null) 'musical_key': musicalKey,
      if (genre != null) 'genre': genre,
      if (period != null) 'period': period,
      if (popular != null) 'popular': popular,
      if (recommended != null) 'recommended': recommended,
      if (source != null) 'source': source,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorksCompanion copyWith({
    Value<String>? id,
    Value<String>? composer,
    Value<String>? title,
    Value<String?>? catalogNumber,
    Value<String?>? musicalKey,
    Value<String?>? genre,
    Value<String?>? period,
    Value<bool>? popular,
    Value<bool>? recommended,
    Value<String>? source,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return WorksCompanion(
      id: id ?? this.id,
      composer: composer ?? this.composer,
      title: title ?? this.title,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      musicalKey: musicalKey ?? this.musicalKey,
      genre: genre ?? this.genre,
      period: period ?? this.period,
      popular: popular ?? this.popular,
      recommended: recommended ?? this.recommended,
      source: source ?? this.source,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (composer.present) {
      map['composer'] = Variable<String>(composer.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (catalogNumber.present) {
      map['catalog_number'] = Variable<String>(catalogNumber.value);
    }
    if (musicalKey.present) {
      map['musical_key'] = Variable<String>(musicalKey.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (popular.present) {
      map['popular'] = Variable<bool>(popular.value);
    }
    if (recommended.present) {
      map['recommended'] = Variable<bool>(recommended.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorksCompanion(')
          ..write('id: $id, ')
          ..write('composer: $composer, ')
          ..write('title: $title, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('genre: $genre, ')
          ..write('period: $period, ')
          ..write('popular: $popular, ')
          ..write('recommended: $recommended, ')
          ..write('source: $source, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkMovementsTable extends WorkMovements
    with TableInfo<$WorkMovementsTable, WorkMovementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id)',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempoMarkMeta = const VerificationMeta(
    'tempoMark',
  );
  @override
  late final GeneratedColumn<String> tempoMark = GeneratedColumn<String>(
    'tempo_mark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [workId, seq, title, tempoMark];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkMovementData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('tempo_mark')) {
      context.handle(
        _tempoMarkMeta,
        tempoMark.isAcceptableOrUnknown(data['tempo_mark']!, _tempoMarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, seq};
  @override
  WorkMovementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkMovementData(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      tempoMark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tempo_mark'],
      ),
    );
  }

  @override
  $WorkMovementsTable createAlias(String alias) {
    return $WorkMovementsTable(attachedDatabase, alias);
  }
}

class WorkMovementData extends DataClass
    implements Insertable<WorkMovementData> {
  final String workId;
  final int seq;
  final String title;
  final String? tempoMark;
  const WorkMovementData({
    required this.workId,
    required this.seq,
    required this.title,
    this.tempoMark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<String>(workId);
    map['seq'] = Variable<int>(seq);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || tempoMark != null) {
      map['tempo_mark'] = Variable<String>(tempoMark);
    }
    return map;
  }

  WorkMovementsCompanion toCompanion(bool nullToAbsent) {
    return WorkMovementsCompanion(
      workId: Value(workId),
      seq: Value(seq),
      title: Value(title),
      tempoMark: tempoMark == null && nullToAbsent
          ? const Value.absent()
          : Value(tempoMark),
    );
  }

  factory WorkMovementData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkMovementData(
      workId: serializer.fromJson<String>(json['workId']),
      seq: serializer.fromJson<int>(json['seq']),
      title: serializer.fromJson<String>(json['title']),
      tempoMark: serializer.fromJson<String?>(json['tempoMark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<String>(workId),
      'seq': serializer.toJson<int>(seq),
      'title': serializer.toJson<String>(title),
      'tempoMark': serializer.toJson<String?>(tempoMark),
    };
  }

  WorkMovementData copyWith({
    String? workId,
    int? seq,
    String? title,
    Value<String?> tempoMark = const Value.absent(),
  }) => WorkMovementData(
    workId: workId ?? this.workId,
    seq: seq ?? this.seq,
    title: title ?? this.title,
    tempoMark: tempoMark.present ? tempoMark.value : this.tempoMark,
  );
  WorkMovementData copyWithCompanion(WorkMovementsCompanion data) {
    return WorkMovementData(
      workId: data.workId.present ? data.workId.value : this.workId,
      seq: data.seq.present ? data.seq.value : this.seq,
      title: data.title.present ? data.title.value : this.title,
      tempoMark: data.tempoMark.present ? data.tempoMark.value : this.tempoMark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkMovementData(')
          ..write('workId: $workId, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('tempoMark: $tempoMark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, seq, title, tempoMark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkMovementData &&
          other.workId == this.workId &&
          other.seq == this.seq &&
          other.title == this.title &&
          other.tempoMark == this.tempoMark);
}

class WorkMovementsCompanion extends UpdateCompanion<WorkMovementData> {
  final Value<String> workId;
  final Value<int> seq;
  final Value<String> title;
  final Value<String?> tempoMark;
  final Value<int> rowid;
  const WorkMovementsCompanion({
    this.workId = const Value.absent(),
    this.seq = const Value.absent(),
    this.title = const Value.absent(),
    this.tempoMark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkMovementsCompanion.insert({
    required String workId,
    required int seq,
    required String title,
    this.tempoMark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       seq = Value(seq),
       title = Value(title);
  static Insertable<WorkMovementData> custom({
    Expression<String>? workId,
    Expression<int>? seq,
    Expression<String>? title,
    Expression<String>? tempoMark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (seq != null) 'seq': seq,
      if (title != null) 'title': title,
      if (tempoMark != null) 'tempo_mark': tempoMark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkMovementsCompanion copyWith({
    Value<String>? workId,
    Value<int>? seq,
    Value<String>? title,
    Value<String?>? tempoMark,
    Value<int>? rowid,
  }) {
    return WorkMovementsCompanion(
      workId: workId ?? this.workId,
      seq: seq ?? this.seq,
      title: title ?? this.title,
      tempoMark: tempoMark ?? this.tempoMark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (tempoMark.present) {
      map['tempo_mark'] = Variable<String>(tempoMark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkMovementsCompanion(')
          ..write('workId: $workId, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('tempoMark: $tempoMark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkAliasesTable extends WorkAliases
    with TableInfo<$WorkAliasesTable, WorkAliasData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id)',
    ),
  );
  static const VerificationMeta _composerKeyMeta = const VerificationMeta(
    'composerKey',
  );
  @override
  late final GeneratedColumn<String> composerKey = GeneratedColumn<String>(
    'composer_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workId,
    composerKey,
    alias,
    language,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkAliasData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    }
    if (data.containsKey('composer_key')) {
      context.handle(
        _composerKeyMeta,
        composerKey.isAcceptableOrUnknown(
          data['composer_key']!,
          _composerKeyMeta,
        ),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkAliasData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkAliasData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      ),
      composerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composer_key'],
      ),
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
    );
  }

  @override
  $WorkAliasesTable createAlias(String alias) {
    return $WorkAliasesTable(attachedDatabase, alias);
  }
}

class WorkAliasData extends DataClass implements Insertable<WorkAliasData> {
  final String id;
  final String? workId;
  final String? composerKey;
  final String alias;
  final String? language;
  const WorkAliasData({
    required this.id,
    this.workId,
    this.composerKey,
    required this.alias,
    this.language,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || workId != null) {
      map['work_id'] = Variable<String>(workId);
    }
    if (!nullToAbsent || composerKey != null) {
      map['composer_key'] = Variable<String>(composerKey);
    }
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    return map;
  }

  WorkAliasesCompanion toCompanion(bool nullToAbsent) {
    return WorkAliasesCompanion(
      id: Value(id),
      workId: workId == null && nullToAbsent
          ? const Value.absent()
          : Value(workId),
      composerKey: composerKey == null && nullToAbsent
          ? const Value.absent()
          : Value(composerKey),
      alias: Value(alias),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
    );
  }

  factory WorkAliasData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkAliasData(
      id: serializer.fromJson<String>(json['id']),
      workId: serializer.fromJson<String?>(json['workId']),
      composerKey: serializer.fromJson<String?>(json['composerKey']),
      alias: serializer.fromJson<String>(json['alias']),
      language: serializer.fromJson<String?>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workId': serializer.toJson<String?>(workId),
      'composerKey': serializer.toJson<String?>(composerKey),
      'alias': serializer.toJson<String>(alias),
      'language': serializer.toJson<String?>(language),
    };
  }

  WorkAliasData copyWith({
    String? id,
    Value<String?> workId = const Value.absent(),
    Value<String?> composerKey = const Value.absent(),
    String? alias,
    Value<String?> language = const Value.absent(),
  }) => WorkAliasData(
    id: id ?? this.id,
    workId: workId.present ? workId.value : this.workId,
    composerKey: composerKey.present ? composerKey.value : this.composerKey,
    alias: alias ?? this.alias,
    language: language.present ? language.value : this.language,
  );
  WorkAliasData copyWithCompanion(WorkAliasesCompanion data) {
    return WorkAliasData(
      id: data.id.present ? data.id.value : this.id,
      workId: data.workId.present ? data.workId.value : this.workId,
      composerKey: data.composerKey.present
          ? data.composerKey.value
          : this.composerKey,
      alias: data.alias.present ? data.alias.value : this.alias,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkAliasData(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('composerKey: $composerKey, ')
          ..write('alias: $alias, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workId, composerKey, alias, language);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkAliasData &&
          other.id == this.id &&
          other.workId == this.workId &&
          other.composerKey == this.composerKey &&
          other.alias == this.alias &&
          other.language == this.language);
}

class WorkAliasesCompanion extends UpdateCompanion<WorkAliasData> {
  final Value<String> id;
  final Value<String?> workId;
  final Value<String?> composerKey;
  final Value<String> alias;
  final Value<String?> language;
  final Value<int> rowid;
  const WorkAliasesCompanion({
    this.id = const Value.absent(),
    this.workId = const Value.absent(),
    this.composerKey = const Value.absent(),
    this.alias = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkAliasesCompanion.insert({
    required String id,
    this.workId = const Value.absent(),
    this.composerKey = const Value.absent(),
    required String alias,
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       alias = Value(alias);
  static Insertable<WorkAliasData> custom({
    Expression<String>? id,
    Expression<String>? workId,
    Expression<String>? composerKey,
    Expression<String>? alias,
    Expression<String>? language,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workId != null) 'work_id': workId,
      if (composerKey != null) 'composer_key': composerKey,
      if (alias != null) 'alias': alias,
      if (language != null) 'language': language,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkAliasesCompanion copyWith({
    Value<String>? id,
    Value<String?>? workId,
    Value<String?>? composerKey,
    Value<String>? alias,
    Value<String?>? language,
    Value<int>? rowid,
  }) {
    return WorkAliasesCompanion(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      composerKey: composerKey ?? this.composerKey,
      alias: alias ?? this.alias,
      language: language ?? this.language,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (composerKey.present) {
      map['composer_key'] = Variable<String>(composerKey.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkAliasesCompanion(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('composerKey: $composerKey, ')
          ..write('alias: $alias, ')
          ..write('language: $language, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentariesTable extends Commentaries
    with TableInfo<$CommentariesTable, CommentaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id)',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    workId,
    language,
    body,
    version,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commentaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentaryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, language};
  @override
  CommentaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentaryData(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CommentariesTable createAlias(String alias) {
    return $CommentariesTable(attachedDatabase, alias);
  }
}

class CommentaryData extends DataClass implements Insertable<CommentaryData> {
  final String workId;
  final String language;
  final String body;
  final int version;
  final DateTime cachedAt;
  const CommentaryData({
    required this.workId,
    required this.language,
    required this.body,
    required this.version,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<String>(workId);
    map['language'] = Variable<String>(language);
    map['body'] = Variable<String>(body);
    map['version'] = Variable<int>(version);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CommentariesCompanion toCompanion(bool nullToAbsent) {
    return CommentariesCompanion(
      workId: Value(workId),
      language: Value(language),
      body: Value(body),
      version: Value(version),
      cachedAt: Value(cachedAt),
    );
  }

  factory CommentaryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentaryData(
      workId: serializer.fromJson<String>(json['workId']),
      language: serializer.fromJson<String>(json['language']),
      body: serializer.fromJson<String>(json['body']),
      version: serializer.fromJson<int>(json['version']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<String>(workId),
      'language': serializer.toJson<String>(language),
      'body': serializer.toJson<String>(body),
      'version': serializer.toJson<int>(version),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CommentaryData copyWith({
    String? workId,
    String? language,
    String? body,
    int? version,
    DateTime? cachedAt,
  }) => CommentaryData(
    workId: workId ?? this.workId,
    language: language ?? this.language,
    body: body ?? this.body,
    version: version ?? this.version,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CommentaryData copyWithCompanion(CommentariesCompanion data) {
    return CommentaryData(
      workId: data.workId.present ? data.workId.value : this.workId,
      language: data.language.present ? data.language.value : this.language,
      body: data.body.present ? data.body.value : this.body,
      version: data.version.present ? data.version.value : this.version,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentaryData(')
          ..write('workId: $workId, ')
          ..write('language: $language, ')
          ..write('body: $body, ')
          ..write('version: $version, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, language, body, version, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentaryData &&
          other.workId == this.workId &&
          other.language == this.language &&
          other.body == this.body &&
          other.version == this.version &&
          other.cachedAt == this.cachedAt);
}

class CommentariesCompanion extends UpdateCompanion<CommentaryData> {
  final Value<String> workId;
  final Value<String> language;
  final Value<String> body;
  final Value<int> version;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CommentariesCompanion({
    this.workId = const Value.absent(),
    this.language = const Value.absent(),
    this.body = const Value.absent(),
    this.version = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentariesCompanion.insert({
    required String workId,
    required String language,
    required String body,
    this.version = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       language = Value(language),
       body = Value(body);
  static Insertable<CommentaryData> custom({
    Expression<String>? workId,
    Expression<String>? language,
    Expression<String>? body,
    Expression<int>? version,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (language != null) 'language': language,
      if (body != null) 'body': body,
      if (version != null) 'version': version,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentariesCompanion copyWith({
    Value<String>? workId,
    Value<String>? language,
    Value<String>? body,
    Value<int>? version,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CommentariesCompanion(
      workId: workId ?? this.workId,
      language: language ?? this.language,
      body: body ?? this.body,
      version: version ?? this.version,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentariesCompanion(')
          ..write('workId: $workId, ')
          ..write('language: $language, ')
          ..write('body: $body, ')
          ..write('version: $version, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, AlbumData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discCountMeta = const VerificationMeta(
    'discCount',
  );
  @override
  late final GeneratedColumn<int> discCount = GeneratedColumn<int>(
    'disc_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _disposedAtMeta = const VerificationMeta(
    'disposedAt',
  );
  @override
  late final GeneratedColumn<DateTime> disposedAt = GeneratedColumn<DateTime>(
    'disposed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    label,
    releaseYear,
    discCount,
    format,
    barcode,
    coverUrl,
    location,
    review,
    acquiredAt,
    disposedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('disc_count')) {
      context.handle(
        _discCountMeta,
        discCount.isAcceptableOrUnknown(data['disc_count']!, _discCountMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    }
    if (data.containsKey('disposed_at')) {
      context.handle(
        _disposedAtMeta,
        disposedAt.isAcceptableOrUnknown(data['disposed_at']!, _disposedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      discCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_count'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      ),
      disposedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}disposed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class AlbumData extends DataClass implements Insertable<AlbumData> {
  final String id;
  final String userId;
  final String title;
  final String? label;
  final int? releaseYear;
  final int discCount;
  final String? format;
  final String? barcode;
  final String? coverUrl;
  final String? location;
  final String? review;
  final DateTime? acquiredAt;
  final DateTime? disposedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AlbumData({
    required this.id,
    required this.userId,
    required this.title,
    this.label,
    this.releaseYear,
    required this.discCount,
    this.format,
    this.barcode,
    this.coverUrl,
    this.location,
    this.review,
    this.acquiredAt,
    this.disposedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    map['disc_count'] = Variable<int>(discCount);
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt);
    }
    if (!nullToAbsent || disposedAt != null) {
      map['disposed_at'] = Variable<DateTime>(disposedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      discCount: Value(discCount),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      disposedAt: disposedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disposedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AlbumData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      label: serializer.fromJson<String?>(json['label']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      discCount: serializer.fromJson<int>(json['discCount']),
      format: serializer.fromJson<String?>(json['format']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      location: serializer.fromJson<String?>(json['location']),
      review: serializer.fromJson<String?>(json['review']),
      acquiredAt: serializer.fromJson<DateTime?>(json['acquiredAt']),
      disposedAt: serializer.fromJson<DateTime?>(json['disposedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'label': serializer.toJson<String?>(label),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'discCount': serializer.toJson<int>(discCount),
      'format': serializer.toJson<String?>(format),
      'barcode': serializer.toJson<String?>(barcode),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'location': serializer.toJson<String?>(location),
      'review': serializer.toJson<String?>(review),
      'acquiredAt': serializer.toJson<DateTime?>(acquiredAt),
      'disposedAt': serializer.toJson<DateTime?>(disposedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AlbumData copyWith({
    String? id,
    String? userId,
    String? title,
    Value<String?> label = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    int? discCount,
    Value<String?> format = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> review = const Value.absent(),
    Value<DateTime?> acquiredAt = const Value.absent(),
    Value<DateTime?> disposedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AlbumData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    label: label.present ? label.value : this.label,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    discCount: discCount ?? this.discCount,
    format: format.present ? format.value : this.format,
    barcode: barcode.present ? barcode.value : this.barcode,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    location: location.present ? location.value : this.location,
    review: review.present ? review.value : this.review,
    acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
    disposedAt: disposedAt.present ? disposedAt.value : this.disposedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AlbumData copyWithCompanion(AlbumsCompanion data) {
    return AlbumData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      label: data.label.present ? data.label.value : this.label,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      discCount: data.discCount.present ? data.discCount.value : this.discCount,
      format: data.format.present ? data.format.value : this.format,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      location: data.location.present ? data.location.value : this.location,
      review: data.review.present ? data.review.value : this.review,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      disposedAt: data.disposedAt.present
          ? data.disposedAt.value
          : this.disposedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('label: $label, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('discCount: $discCount, ')
          ..write('format: $format, ')
          ..write('barcode: $barcode, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('location: $location, ')
          ..write('review: $review, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('disposedAt: $disposedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    label,
    releaseYear,
    discCount,
    format,
    barcode,
    coverUrl,
    location,
    review,
    acquiredAt,
    disposedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.label == this.label &&
          other.releaseYear == this.releaseYear &&
          other.discCount == this.discCount &&
          other.format == this.format &&
          other.barcode == this.barcode &&
          other.coverUrl == this.coverUrl &&
          other.location == this.location &&
          other.review == this.review &&
          other.acquiredAt == this.acquiredAt &&
          other.disposedAt == this.disposedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AlbumsCompanion extends UpdateCompanion<AlbumData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> label;
  final Value<int?> releaseYear;
  final Value<int> discCount;
  final Value<String?> format;
  final Value<String?> barcode;
  final Value<String?> coverUrl;
  final Value<String?> location;
  final Value<String?> review;
  final Value<DateTime?> acquiredAt;
  final Value<DateTime?> disposedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.label = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.discCount = const Value.absent(),
    this.format = const Value.absent(),
    this.barcode = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.location = const Value.absent(),
    this.review = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.disposedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.label = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.discCount = const Value.absent(),
    this.format = const Value.absent(),
    this.barcode = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.location = const Value.absent(),
    this.review = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.disposedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title);
  static Insertable<AlbumData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? label,
    Expression<int>? releaseYear,
    Expression<int>? discCount,
    Expression<String>? format,
    Expression<String>? barcode,
    Expression<String>? coverUrl,
    Expression<String>? location,
    Expression<String>? review,
    Expression<DateTime>? acquiredAt,
    Expression<DateTime>? disposedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (label != null) 'label': label,
      if (releaseYear != null) 'release_year': releaseYear,
      if (discCount != null) 'disc_count': discCount,
      if (format != null) 'format': format,
      if (barcode != null) 'barcode': barcode,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (location != null) 'location': location,
      if (review != null) 'review': review,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (disposedAt != null) 'disposed_at': disposedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? label,
    Value<int?>? releaseYear,
    Value<int>? discCount,
    Value<String?>? format,
    Value<String?>? barcode,
    Value<String?>? coverUrl,
    Value<String?>? location,
    Value<String?>? review,
    Value<DateTime?>? acquiredAt,
    Value<DateTime?>? disposedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      label: label ?? this.label,
      releaseYear: releaseYear ?? this.releaseYear,
      discCount: discCount ?? this.discCount,
      format: format ?? this.format,
      barcode: barcode ?? this.barcode,
      coverUrl: coverUrl ?? this.coverUrl,
      location: location ?? this.location,
      review: review ?? this.review,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      disposedAt: disposedAt ?? this.disposedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (discCount.present) {
      map['disc_count'] = Variable<int>(discCount.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (disposedAt.present) {
      map['disposed_at'] = Variable<DateTime>(disposedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('label: $label, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('discCount: $discCount, ')
          ..write('format: $format, ')
          ..write('barcode: $barcode, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('location: $location, ')
          ..write('review: $review, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('disposedAt: $disposedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompositionsTable extends Compositions
    with TableInfo<$CompositionsTable, CompositionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id)',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _composerMeta = const VerificationMeta(
    'composer',
  );
  @override
  late final GeneratedColumn<String> composer = GeneratedColumn<String>(
    'composer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogNumberMeta = const VerificationMeta(
    'catalogNumber',
  );
  @override
  late final GeneratedColumn<String> catalogNumber = GeneratedColumn<String>(
    'catalog_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discNoMeta = const VerificationMeta('discNo');
  @override
  late final GeneratedColumn<int> discNo = GeneratedColumn<int>(
    'disc_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackFromMeta = const VerificationMeta(
    'trackFrom',
  );
  @override
  late final GeneratedColumn<int> trackFrom = GeneratedColumn<int>(
    'track_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackToMeta = const VerificationMeta(
    'trackTo',
  );
  @override
  late final GeneratedColumn<int> trackTo = GeneratedColumn<int>(
    'track_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unverified'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    albumId,
    workId,
    title,
    composer,
    catalogNumber,
    discNo,
    trackFrom,
    trackTo,
    seq,
    confidence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compositions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompositionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('composer')) {
      context.handle(
        _composerMeta,
        composer.isAcceptableOrUnknown(data['composer']!, _composerMeta),
      );
    } else if (isInserting) {
      context.missing(_composerMeta);
    }
    if (data.containsKey('catalog_number')) {
      context.handle(
        _catalogNumberMeta,
        catalogNumber.isAcceptableOrUnknown(
          data['catalog_number']!,
          _catalogNumberMeta,
        ),
      );
    }
    if (data.containsKey('disc_no')) {
      context.handle(
        _discNoMeta,
        discNo.isAcceptableOrUnknown(data['disc_no']!, _discNoMeta),
      );
    }
    if (data.containsKey('track_from')) {
      context.handle(
        _trackFromMeta,
        trackFrom.isAcceptableOrUnknown(data['track_from']!, _trackFromMeta),
      );
    }
    if (data.containsKey('track_to')) {
      context.handle(
        _trackToMeta,
        trackTo.isAcceptableOrUnknown(data['track_to']!, _trackToMeta),
      );
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompositionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompositionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      composer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composer'],
      )!,
      catalogNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_number'],
      ),
      discNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_no'],
      ),
      trackFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_from'],
      ),
      trackTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_to'],
      ),
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CompositionsTable createAlias(String alias) {
    return $CompositionsTable(attachedDatabase, alias);
  }
}

class CompositionData extends DataClass implements Insertable<CompositionData> {
  final String id;
  final String userId;
  final String albumId;
  final String? workId;
  final String? title;
  final String composer;
  final String? catalogNumber;
  final int? discNo;
  final int? trackFrom;
  final int? trackTo;
  final int seq;
  final String confidence;
  final DateTime createdAt;
  const CompositionData({
    required this.id,
    required this.userId,
    required this.albumId,
    this.workId,
    this.title,
    required this.composer,
    this.catalogNumber,
    this.discNo,
    this.trackFrom,
    this.trackTo,
    required this.seq,
    required this.confidence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['album_id'] = Variable<String>(albumId);
    if (!nullToAbsent || workId != null) {
      map['work_id'] = Variable<String>(workId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['composer'] = Variable<String>(composer);
    if (!nullToAbsent || catalogNumber != null) {
      map['catalog_number'] = Variable<String>(catalogNumber);
    }
    if (!nullToAbsent || discNo != null) {
      map['disc_no'] = Variable<int>(discNo);
    }
    if (!nullToAbsent || trackFrom != null) {
      map['track_from'] = Variable<int>(trackFrom);
    }
    if (!nullToAbsent || trackTo != null) {
      map['track_to'] = Variable<int>(trackTo);
    }
    map['seq'] = Variable<int>(seq);
    map['confidence'] = Variable<String>(confidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CompositionsCompanion toCompanion(bool nullToAbsent) {
    return CompositionsCompanion(
      id: Value(id),
      userId: Value(userId),
      albumId: Value(albumId),
      workId: workId == null && nullToAbsent
          ? const Value.absent()
          : Value(workId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      composer: Value(composer),
      catalogNumber: catalogNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogNumber),
      discNo: discNo == null && nullToAbsent
          ? const Value.absent()
          : Value(discNo),
      trackFrom: trackFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(trackFrom),
      trackTo: trackTo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackTo),
      seq: Value(seq),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
    );
  }

  factory CompositionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompositionData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      albumId: serializer.fromJson<String>(json['albumId']),
      workId: serializer.fromJson<String?>(json['workId']),
      title: serializer.fromJson<String?>(json['title']),
      composer: serializer.fromJson<String>(json['composer']),
      catalogNumber: serializer.fromJson<String?>(json['catalogNumber']),
      discNo: serializer.fromJson<int?>(json['discNo']),
      trackFrom: serializer.fromJson<int?>(json['trackFrom']),
      trackTo: serializer.fromJson<int?>(json['trackTo']),
      seq: serializer.fromJson<int>(json['seq']),
      confidence: serializer.fromJson<String>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'albumId': serializer.toJson<String>(albumId),
      'workId': serializer.toJson<String?>(workId),
      'title': serializer.toJson<String?>(title),
      'composer': serializer.toJson<String>(composer),
      'catalogNumber': serializer.toJson<String?>(catalogNumber),
      'discNo': serializer.toJson<int?>(discNo),
      'trackFrom': serializer.toJson<int?>(trackFrom),
      'trackTo': serializer.toJson<int?>(trackTo),
      'seq': serializer.toJson<int>(seq),
      'confidence': serializer.toJson<String>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CompositionData copyWith({
    String? id,
    String? userId,
    String? albumId,
    Value<String?> workId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    String? composer,
    Value<String?> catalogNumber = const Value.absent(),
    Value<int?> discNo = const Value.absent(),
    Value<int?> trackFrom = const Value.absent(),
    Value<int?> trackTo = const Value.absent(),
    int? seq,
    String? confidence,
    DateTime? createdAt,
  }) => CompositionData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    albumId: albumId ?? this.albumId,
    workId: workId.present ? workId.value : this.workId,
    title: title.present ? title.value : this.title,
    composer: composer ?? this.composer,
    catalogNumber: catalogNumber.present
        ? catalogNumber.value
        : this.catalogNumber,
    discNo: discNo.present ? discNo.value : this.discNo,
    trackFrom: trackFrom.present ? trackFrom.value : this.trackFrom,
    trackTo: trackTo.present ? trackTo.value : this.trackTo,
    seq: seq ?? this.seq,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt ?? this.createdAt,
  );
  CompositionData copyWithCompanion(CompositionsCompanion data) {
    return CompositionData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      workId: data.workId.present ? data.workId.value : this.workId,
      title: data.title.present ? data.title.value : this.title,
      composer: data.composer.present ? data.composer.value : this.composer,
      catalogNumber: data.catalogNumber.present
          ? data.catalogNumber.value
          : this.catalogNumber,
      discNo: data.discNo.present ? data.discNo.value : this.discNo,
      trackFrom: data.trackFrom.present ? data.trackFrom.value : this.trackFrom,
      trackTo: data.trackTo.present ? data.trackTo.value : this.trackTo,
      seq: data.seq.present ? data.seq.value : this.seq,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompositionData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('albumId: $albumId, ')
          ..write('workId: $workId, ')
          ..write('title: $title, ')
          ..write('composer: $composer, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('discNo: $discNo, ')
          ..write('trackFrom: $trackFrom, ')
          ..write('trackTo: $trackTo, ')
          ..write('seq: $seq, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    albumId,
    workId,
    title,
    composer,
    catalogNumber,
    discNo,
    trackFrom,
    trackTo,
    seq,
    confidence,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompositionData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.albumId == this.albumId &&
          other.workId == this.workId &&
          other.title == this.title &&
          other.composer == this.composer &&
          other.catalogNumber == this.catalogNumber &&
          other.discNo == this.discNo &&
          other.trackFrom == this.trackFrom &&
          other.trackTo == this.trackTo &&
          other.seq == this.seq &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt);
}

class CompositionsCompanion extends UpdateCompanion<CompositionData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> albumId;
  final Value<String?> workId;
  final Value<String?> title;
  final Value<String> composer;
  final Value<String?> catalogNumber;
  final Value<int?> discNo;
  final Value<int?> trackFrom;
  final Value<int?> trackTo;
  final Value<int> seq;
  final Value<String> confidence;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CompositionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.workId = const Value.absent(),
    this.title = const Value.absent(),
    this.composer = const Value.absent(),
    this.catalogNumber = const Value.absent(),
    this.discNo = const Value.absent(),
    this.trackFrom = const Value.absent(),
    this.trackTo = const Value.absent(),
    this.seq = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompositionsCompanion.insert({
    required String id,
    required String userId,
    required String albumId,
    this.workId = const Value.absent(),
    this.title = const Value.absent(),
    required String composer,
    this.catalogNumber = const Value.absent(),
    this.discNo = const Value.absent(),
    this.trackFrom = const Value.absent(),
    this.trackTo = const Value.absent(),
    this.seq = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       albumId = Value(albumId),
       composer = Value(composer);
  static Insertable<CompositionData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? albumId,
    Expression<String>? workId,
    Expression<String>? title,
    Expression<String>? composer,
    Expression<String>? catalogNumber,
    Expression<int>? discNo,
    Expression<int>? trackFrom,
    Expression<int>? trackTo,
    Expression<int>? seq,
    Expression<String>? confidence,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (albumId != null) 'album_id': albumId,
      if (workId != null) 'work_id': workId,
      if (title != null) 'title': title,
      if (composer != null) 'composer': composer,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (discNo != null) 'disc_no': discNo,
      if (trackFrom != null) 'track_from': trackFrom,
      if (trackTo != null) 'track_to': trackTo,
      if (seq != null) 'seq': seq,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompositionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? albumId,
    Value<String?>? workId,
    Value<String?>? title,
    Value<String>? composer,
    Value<String?>? catalogNumber,
    Value<int?>? discNo,
    Value<int?>? trackFrom,
    Value<int?>? trackTo,
    Value<int>? seq,
    Value<String>? confidence,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CompositionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      albumId: albumId ?? this.albumId,
      workId: workId ?? this.workId,
      title: title ?? this.title,
      composer: composer ?? this.composer,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      discNo: discNo ?? this.discNo,
      trackFrom: trackFrom ?? this.trackFrom,
      trackTo: trackTo ?? this.trackTo,
      seq: seq ?? this.seq,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (composer.present) {
      map['composer'] = Variable<String>(composer.value);
    }
    if (catalogNumber.present) {
      map['catalog_number'] = Variable<String>(catalogNumber.value);
    }
    if (discNo.present) {
      map['disc_no'] = Variable<int>(discNo.value);
    }
    if (trackFrom.present) {
      map['track_from'] = Variable<int>(trackFrom.value);
    }
    if (trackTo.present) {
      map['track_to'] = Variable<int>(trackTo.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompositionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('albumId: $albumId, ')
          ..write('workId: $workId, ')
          ..write('title: $title, ')
          ..write('composer: $composer, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('discNo: $discNo, ')
          ..write('trackFrom: $trackFrom, ')
          ..write('trackTo: $trackTo, ')
          ..write('seq: $seq, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, MovementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compositionIdMeta = const VerificationMeta(
    'compositionId',
  );
  @override
  late final GeneratedColumn<String> compositionId = GeneratedColumn<String>(
    'composition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compositions (id)',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackNoMeta = const VerificationMeta(
    'trackNo',
  );
  @override
  late final GeneratedColumn<int> trackNo = GeneratedColumn<int>(
    'track_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    compositionId,
    seq,
    title,
    trackNo,
    durationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('composition_id')) {
      context.handle(
        _compositionIdMeta,
        compositionId.isAcceptableOrUnknown(
          data['composition_id']!,
          _compositionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compositionIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('track_no')) {
      context.handle(
        _trackNoMeta,
        trackNo.isAcceptableOrUnknown(data['track_no']!, _trackNoMeta),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      compositionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composition_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      trackNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_no'],
      ),
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }
}

class MovementData extends DataClass implements Insertable<MovementData> {
  final String id;
  final String userId;
  final String compositionId;
  final int seq;
  final String title;
  final int? trackNo;
  final int? durationSec;
  const MovementData({
    required this.id,
    required this.userId,
    required this.compositionId,
    required this.seq,
    required this.title,
    this.trackNo,
    this.durationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['composition_id'] = Variable<String>(compositionId);
    map['seq'] = Variable<int>(seq);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || trackNo != null) {
      map['track_no'] = Variable<int>(trackNo);
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      userId: Value(userId),
      compositionId: Value(compositionId),
      seq: Value(seq),
      title: Value(title),
      trackNo: trackNo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNo),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
    );
  }

  factory MovementData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      compositionId: serializer.fromJson<String>(json['compositionId']),
      seq: serializer.fromJson<int>(json['seq']),
      title: serializer.fromJson<String>(json['title']),
      trackNo: serializer.fromJson<int?>(json['trackNo']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'compositionId': serializer.toJson<String>(compositionId),
      'seq': serializer.toJson<int>(seq),
      'title': serializer.toJson<String>(title),
      'trackNo': serializer.toJson<int?>(trackNo),
      'durationSec': serializer.toJson<int?>(durationSec),
    };
  }

  MovementData copyWith({
    String? id,
    String? userId,
    String? compositionId,
    int? seq,
    String? title,
    Value<int?> trackNo = const Value.absent(),
    Value<int?> durationSec = const Value.absent(),
  }) => MovementData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    compositionId: compositionId ?? this.compositionId,
    seq: seq ?? this.seq,
    title: title ?? this.title,
    trackNo: trackNo.present ? trackNo.value : this.trackNo,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
  );
  MovementData copyWithCompanion(MovementsCompanion data) {
    return MovementData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      compositionId: data.compositionId.present
          ? data.compositionId.value
          : this.compositionId,
      seq: data.seq.present ? data.seq.value : this.seq,
      title: data.title.present ? data.title.value : this.title,
      trackNo: data.trackNo.present ? data.trackNo.value : this.trackNo,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('compositionId: $compositionId, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('trackNo: $trackNo, ')
          ..write('durationSec: $durationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, compositionId, seq, title, trackNo, durationSec);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.compositionId == this.compositionId &&
          other.seq == this.seq &&
          other.title == this.title &&
          other.trackNo == this.trackNo &&
          other.durationSec == this.durationSec);
}

class MovementsCompanion extends UpdateCompanion<MovementData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> compositionId;
  final Value<int> seq;
  final Value<String> title;
  final Value<int?> trackNo;
  final Value<int?> durationSec;
  final Value<int> rowid;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.compositionId = const Value.absent(),
    this.seq = const Value.absent(),
    this.title = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementsCompanion.insert({
    required String id,
    required String userId,
    required String compositionId,
    required int seq,
    required String title,
    this.trackNo = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       compositionId = Value(compositionId),
       seq = Value(seq),
       title = Value(title);
  static Insertable<MovementData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? compositionId,
    Expression<int>? seq,
    Expression<String>? title,
    Expression<int>? trackNo,
    Expression<int>? durationSec,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (compositionId != null) 'composition_id': compositionId,
      if (seq != null) 'seq': seq,
      if (title != null) 'title': title,
      if (trackNo != null) 'track_no': trackNo,
      if (durationSec != null) 'duration_sec': durationSec,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? compositionId,
    Value<int>? seq,
    Value<String>? title,
    Value<int?>? trackNo,
    Value<int?>? durationSec,
    Value<int>? rowid,
  }) {
    return MovementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      compositionId: compositionId ?? this.compositionId,
      seq: seq ?? this.seq,
      title: title ?? this.title,
      trackNo: trackNo ?? this.trackNo,
      durationSec: durationSec ?? this.durationSec,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (compositionId.present) {
      map['composition_id'] = Variable<String>(compositionId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (trackNo.present) {
      map['track_no'] = Variable<int>(trackNo.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('compositionId: $compositionId, ')
          ..write('seq: $seq, ')
          ..write('title: $title, ')
          ..write('trackNo: $trackNo, ')
          ..write('durationSec: $durationSec, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumPerformersTable extends AlbumPerformers
    with TableInfo<$AlbumPerformersTable, AlbumPerformerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumPerformersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, albumId, role, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_performers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumPerformerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumPerformerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumPerformerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $AlbumPerformersTable createAlias(String alias) {
    return $AlbumPerformersTable(attachedDatabase, alias);
  }
}

class AlbumPerformerData extends DataClass
    implements Insertable<AlbumPerformerData> {
  final String id;
  final String userId;
  final String albumId;
  final String role;
  final String name;
  const AlbumPerformerData({
    required this.id,
    required this.userId,
    required this.albumId,
    required this.role,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['album_id'] = Variable<String>(albumId);
    map['role'] = Variable<String>(role);
    map['name'] = Variable<String>(name);
    return map;
  }

  AlbumPerformersCompanion toCompanion(bool nullToAbsent) {
    return AlbumPerformersCompanion(
      id: Value(id),
      userId: Value(userId),
      albumId: Value(albumId),
      role: Value(role),
      name: Value(name),
    );
  }

  factory AlbumPerformerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumPerformerData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      albumId: serializer.fromJson<String>(json['albumId']),
      role: serializer.fromJson<String>(json['role']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'albumId': serializer.toJson<String>(albumId),
      'role': serializer.toJson<String>(role),
      'name': serializer.toJson<String>(name),
    };
  }

  AlbumPerformerData copyWith({
    String? id,
    String? userId,
    String? albumId,
    String? role,
    String? name,
  }) => AlbumPerformerData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    albumId: albumId ?? this.albumId,
    role: role ?? this.role,
    name: name ?? this.name,
  );
  AlbumPerformerData copyWithCompanion(AlbumPerformersCompanion data) {
    return AlbumPerformerData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      role: data.role.present ? data.role.value : this.role,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPerformerData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('albumId: $albumId, ')
          ..write('role: $role, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, albumId, role, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumPerformerData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.albumId == this.albumId &&
          other.role == this.role &&
          other.name == this.name);
}

class AlbumPerformersCompanion extends UpdateCompanion<AlbumPerformerData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> albumId;
  final Value<String> role;
  final Value<String> name;
  final Value<int> rowid;
  const AlbumPerformersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.role = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumPerformersCompanion.insert({
    required String id,
    required String userId,
    required String albumId,
    required String role,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       albumId = Value(albumId),
       role = Value(role),
       name = Value(name);
  static Insertable<AlbumPerformerData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? albumId,
    Expression<String>? role,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (albumId != null) 'album_id': albumId,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumPerformersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? albumId,
    Value<String>? role,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return AlbumPerformersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      albumId: albumId ?? this.albumId,
      role: role ?? this.role,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPerformersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('albumId: $albumId, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompositionPerformersTable extends CompositionPerformers
    with TableInfo<$CompositionPerformersTable, CompositionPerformerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompositionPerformersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compositionIdMeta = const VerificationMeta(
    'compositionId',
  );
  @override
  late final GeneratedColumn<String> compositionId = GeneratedColumn<String>(
    'composition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compositions (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, compositionId, role, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'composition_performers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompositionPerformerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('composition_id')) {
      context.handle(
        _compositionIdMeta,
        compositionId.isAcceptableOrUnknown(
          data['composition_id']!,
          _compositionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compositionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompositionPerformerData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompositionPerformerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      compositionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composition_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CompositionPerformersTable createAlias(String alias) {
    return $CompositionPerformersTable(attachedDatabase, alias);
  }
}

class CompositionPerformerData extends DataClass
    implements Insertable<CompositionPerformerData> {
  final String id;
  final String userId;
  final String compositionId;
  final String role;
  final String name;
  const CompositionPerformerData({
    required this.id,
    required this.userId,
    required this.compositionId,
    required this.role,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['composition_id'] = Variable<String>(compositionId);
    map['role'] = Variable<String>(role);
    map['name'] = Variable<String>(name);
    return map;
  }

  CompositionPerformersCompanion toCompanion(bool nullToAbsent) {
    return CompositionPerformersCompanion(
      id: Value(id),
      userId: Value(userId),
      compositionId: Value(compositionId),
      role: Value(role),
      name: Value(name),
    );
  }

  factory CompositionPerformerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompositionPerformerData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      compositionId: serializer.fromJson<String>(json['compositionId']),
      role: serializer.fromJson<String>(json['role']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'compositionId': serializer.toJson<String>(compositionId),
      'role': serializer.toJson<String>(role),
      'name': serializer.toJson<String>(name),
    };
  }

  CompositionPerformerData copyWith({
    String? id,
    String? userId,
    String? compositionId,
    String? role,
    String? name,
  }) => CompositionPerformerData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    compositionId: compositionId ?? this.compositionId,
    role: role ?? this.role,
    name: name ?? this.name,
  );
  CompositionPerformerData copyWithCompanion(
    CompositionPerformersCompanion data,
  ) {
    return CompositionPerformerData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      compositionId: data.compositionId.present
          ? data.compositionId.value
          : this.compositionId,
      role: data.role.present ? data.role.value : this.role,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompositionPerformerData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('compositionId: $compositionId, ')
          ..write('role: $role, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, compositionId, role, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompositionPerformerData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.compositionId == this.compositionId &&
          other.role == this.role &&
          other.name == this.name);
}

class CompositionPerformersCompanion
    extends UpdateCompanion<CompositionPerformerData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> compositionId;
  final Value<String> role;
  final Value<String> name;
  final Value<int> rowid;
  const CompositionPerformersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.compositionId = const Value.absent(),
    this.role = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompositionPerformersCompanion.insert({
    required String id,
    required String userId,
    required String compositionId,
    required String role,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       compositionId = Value(compositionId),
       role = Value(role),
       name = Value(name);
  static Insertable<CompositionPerformerData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? compositionId,
    Expression<String>? role,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (compositionId != null) 'composition_id': compositionId,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompositionPerformersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? compositionId,
    Value<String>? role,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CompositionPerformersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      compositionId: compositionId ?? this.compositionId,
      role: role ?? this.role,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (compositionId.present) {
      map['composition_id'] = Variable<String>(compositionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompositionPerformersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('compositionId: $compositionId, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistTable extends Wishlist
    with TableInfo<$WishlistTable, WishlistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id)',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<String> workId = GeneratedColumn<String>(
    'work_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id)',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    albumId,
    workId,
    priority,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WishlistTable createAlias(String alias) {
    return $WishlistTable(attachedDatabase, alias);
  }
}

class WishlistData extends DataClass implements Insertable<WishlistData> {
  final String id;
  final String userId;
  final String type;
  final String? albumId;
  final String? workId;
  final int? priority;
  final String? note;
  final DateTime createdAt;
  const WishlistData({
    required this.id,
    required this.userId,
    required this.type,
    this.albumId,
    this.workId,
    this.priority,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    if (!nullToAbsent || workId != null) {
      map['work_id'] = Variable<String>(workId);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WishlistCompanion toCompanion(bool nullToAbsent) {
    return WishlistCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      workId: workId == null && nullToAbsent
          ? const Value.absent()
          : Value(workId),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory WishlistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      workId: serializer.fromJson<String?>(json['workId']),
      priority: serializer.fromJson<int?>(json['priority']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'albumId': serializer.toJson<String?>(albumId),
      'workId': serializer.toJson<String?>(workId),
      'priority': serializer.toJson<int?>(priority),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WishlistData copyWith({
    String? id,
    String? userId,
    String? type,
    Value<String?> albumId = const Value.absent(),
    Value<String?> workId = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => WishlistData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    albumId: albumId.present ? albumId.value : this.albumId,
    workId: workId.present ? workId.value : this.workId,
    priority: priority.present ? priority.value : this.priority,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  WishlistData copyWithCompanion(WishlistCompanion data) {
    return WishlistData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      workId: data.workId.present ? data.workId.value : this.workId,
      priority: data.priority.present ? data.priority.value : this.priority,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('albumId: $albumId, ')
          ..write('workId: $workId, ')
          ..write('priority: $priority, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, albumId, workId, priority, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.albumId == this.albumId &&
          other.workId == this.workId &&
          other.priority == this.priority &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class WishlistCompanion extends UpdateCompanion<WishlistData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> albumId;
  final Value<String?> workId;
  final Value<int?> priority;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WishlistCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.albumId = const Value.absent(),
    this.workId = const Value.absent(),
    this.priority = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistCompanion.insert({
    required String id,
    required String userId,
    required String type,
    this.albumId = const Value.absent(),
    this.workId = const Value.absent(),
    this.priority = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type);
  static Insertable<WishlistData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? albumId,
    Expression<String>? workId,
    Expression<int>? priority,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (albumId != null) 'album_id': albumId,
      if (workId != null) 'work_id': workId,
      if (priority != null) 'priority': priority,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String?>? albumId,
    Value<String?>? workId,
    Value<int?>? priority,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WishlistCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      albumId: albumId ?? this.albumId,
      workId: workId ?? this.workId,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<String>(workId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('albumId: $albumId, ')
          ..write('workId: $workId, ')
          ..write('priority: $priority, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    entityId,
    operation,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityTable;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  const SyncQueueData({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityTable,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityTable, entityId, operation, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required String entityId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : entityTable = Value(entityTable),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorksTable works = $WorksTable(this);
  late final $WorkMovementsTable workMovements = $WorkMovementsTable(this);
  late final $WorkAliasesTable workAliases = $WorkAliasesTable(this);
  late final $CommentariesTable commentaries = $CommentariesTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $CompositionsTable compositions = $CompositionsTable(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final $AlbumPerformersTable albumPerformers = $AlbumPerformersTable(
    this,
  );
  late final $CompositionPerformersTable compositionPerformers =
      $CompositionPerformersTable(this);
  late final $WishlistTable wishlist = $WishlistTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    works,
    workMovements,
    workAliases,
    commentaries,
    albums,
    compositions,
    movements,
    albumPerformers,
    compositionPerformers,
    wishlist,
    syncQueue,
  ];
}

typedef $$WorksTableCreateCompanionBuilder =
    WorksCompanion Function({
      required String id,
      required String composer,
      required String title,
      Value<String?> catalogNumber,
      Value<String?> musicalKey,
      Value<String?> genre,
      Value<String?> period,
      Value<bool> popular,
      Value<bool> recommended,
      Value<String> source,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$WorksTableUpdateCompanionBuilder =
    WorksCompanion Function({
      Value<String> id,
      Value<String> composer,
      Value<String> title,
      Value<String?> catalogNumber,
      Value<String?> musicalKey,
      Value<String?> genre,
      Value<String?> period,
      Value<bool> popular,
      Value<bool> recommended,
      Value<String> source,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$WorksTableReferences
    extends BaseReferences<_$AppDatabase, $WorksTable, WorkData> {
  $$WorksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkMovementsTable, List<WorkMovementData>>
  _workMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workMovements,
    aliasName: 'works__id__work_movements__work_id',
  );

  $$WorkMovementsTableProcessedTableManager get workMovementsRefs {
    final manager = $$WorkMovementsTableTableManager(
      $_db,
      $_db.workMovements,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkAliasesTable, List<WorkAliasData>>
  _workAliasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workAliases,
    aliasName: 'works__id__work_aliases__work_id',
  );

  $$WorkAliasesTableProcessedTableManager get workAliasesRefs {
    final manager = $$WorkAliasesTableTableManager(
      $_db,
      $_db.workAliases,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workAliasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommentariesTable, List<CommentaryData>>
  _commentariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commentaries,
    aliasName: 'works__id__commentaries__work_id',
  );

  $$CommentariesTableProcessedTableManager get commentariesRefs {
    final manager = $$CommentariesTableTableManager(
      $_db,
      $_db.commentaries,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentariesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompositionsTable, List<CompositionData>>
  _compositionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compositions,
    aliasName: 'works__id__compositions__work_id',
  );

  $$CompositionsTableProcessedTableManager get compositionsRefs {
    final manager = $$CompositionsTableTableManager(
      $_db,
      $_db.compositions,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_compositionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WishlistTable, List<WishlistData>>
  _wishlistRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wishlist,
    aliasName: 'works__id__wishlist__work_id',
  );

  $$WishlistTableProcessedTableManager get wishlistRefs {
    final manager = $$WishlistTableTableManager(
      $_db,
      $_db.wishlist,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wishlistRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorksTableFilterComposer extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get composer => $composableBuilder(
    column: $table.composer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workMovementsRefs(
    Expression<bool> Function($$WorkMovementsTableFilterComposer f) f,
  ) {
    final $$WorkMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workMovements,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkMovementsTableFilterComposer(
            $db: $db,
            $table: $db.workMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workAliasesRefs(
    Expression<bool> Function($$WorkAliasesTableFilterComposer f) f,
  ) {
    final $$WorkAliasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workAliases,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkAliasesTableFilterComposer(
            $db: $db,
            $table: $db.workAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commentariesRefs(
    Expression<bool> Function($$CommentariesTableFilterComposer f) f,
  ) {
    final $$CommentariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commentaries,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentariesTableFilterComposer(
            $db: $db,
            $table: $db.commentaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compositionsRefs(
    Expression<bool> Function($$CompositionsTableFilterComposer f) f,
  ) {
    final $$CompositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableFilterComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wishlistRefs(
    Expression<bool> Function($$WishlistTableFilterComposer f) f,
  ) {
    final $$WishlistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlist,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistTableFilterComposer(
            $db: $db,
            $table: $db.wishlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorksTableOrderingComposer
    extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get composer => $composableBuilder(
    column: $table.composer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get composer =>
      $composableBuilder(column: $table.composer, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<bool> get popular =>
      $composableBuilder(column: $table.popular, builder: (column) => column);

  GeneratedColumn<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  Expression<T> workMovementsRefs<T extends Object>(
    Expression<T> Function($$WorkMovementsTableAnnotationComposer a) f,
  ) {
    final $$WorkMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workMovements,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.workMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workAliasesRefs<T extends Object>(
    Expression<T> Function($$WorkAliasesTableAnnotationComposer a) f,
  ) {
    final $$WorkAliasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workAliases,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkAliasesTableAnnotationComposer(
            $db: $db,
            $table: $db.workAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commentariesRefs<T extends Object>(
    Expression<T> Function($$CommentariesTableAnnotationComposer a) f,
  ) {
    final $$CommentariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commentaries,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentariesTableAnnotationComposer(
            $db: $db,
            $table: $db.commentaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compositionsRefs<T extends Object>(
    Expression<T> Function($$CompositionsTableAnnotationComposer a) f,
  ) {
    final $$CompositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wishlistRefs<T extends Object>(
    Expression<T> Function($$WishlistTableAnnotationComposer a) f,
  ) {
    final $$WishlistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlist,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistTableAnnotationComposer(
            $db: $db,
            $table: $db.wishlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorksTable,
          WorkData,
          $$WorksTableFilterComposer,
          $$WorksTableOrderingComposer,
          $$WorksTableAnnotationComposer,
          $$WorksTableCreateCompanionBuilder,
          $$WorksTableUpdateCompanionBuilder,
          (WorkData, $$WorksTableReferences),
          WorkData,
          PrefetchHooks Function({
            bool workMovementsRefs,
            bool workAliasesRefs,
            bool commentariesRefs,
            bool compositionsRefs,
            bool wishlistRefs,
          })
        > {
  $$WorksTableTableManager(_$AppDatabase db, $WorksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> composer = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> catalogNumber = const Value.absent(),
                Value<String?> musicalKey = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<bool> popular = const Value.absent(),
                Value<bool> recommended = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorksCompanion(
                id: id,
                composer: composer,
                title: title,
                catalogNumber: catalogNumber,
                musicalKey: musicalKey,
                genre: genre,
                period: period,
                popular: popular,
                recommended: recommended,
                source: source,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String composer,
                required String title,
                Value<String?> catalogNumber = const Value.absent(),
                Value<String?> musicalKey = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<bool> popular = const Value.absent(),
                Value<bool> recommended = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorksCompanion.insert(
                id: id,
                composer: composer,
                title: title,
                catalogNumber: catalogNumber,
                musicalKey: musicalKey,
                genre: genre,
                period: period,
                popular: popular,
                recommended: recommended,
                source: source,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WorksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workMovementsRefs = false,
                workAliasesRefs = false,
                commentariesRefs = false,
                compositionsRefs = false,
                wishlistRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workMovementsRefs) db.workMovements,
                    if (workAliasesRefs) db.workAliases,
                    if (commentariesRefs) db.commentaries,
                    if (compositionsRefs) db.compositions,
                    if (wishlistRefs) db.wishlist,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workMovementsRefs)
                        await $_getPrefetchedData<
                          WorkData,
                          $WorksTable,
                          WorkMovementData
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workAliasesRefs)
                        await $_getPrefetchedData<
                          WorkData,
                          $WorksTable,
                          WorkAliasData
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workAliasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workAliasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commentariesRefs)
                        await $_getPrefetchedData<
                          WorkData,
                          $WorksTable,
                          CommentaryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._commentariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).commentariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (compositionsRefs)
                        await $_getPrefetchedData<
                          WorkData,
                          $WorksTable,
                          CompositionData
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._compositionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).compositionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wishlistRefs)
                        await $_getPrefetchedData<
                          WorkData,
                          $WorksTable,
                          WishlistData
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._wishlistRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).wishlistRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorksTable,
      WorkData,
      $$WorksTableFilterComposer,
      $$WorksTableOrderingComposer,
      $$WorksTableAnnotationComposer,
      $$WorksTableCreateCompanionBuilder,
      $$WorksTableUpdateCompanionBuilder,
      (WorkData, $$WorksTableReferences),
      WorkData,
      PrefetchHooks Function({
        bool workMovementsRefs,
        bool workAliasesRefs,
        bool commentariesRefs,
        bool compositionsRefs,
        bool wishlistRefs,
      })
    >;
typedef $$WorkMovementsTableCreateCompanionBuilder =
    WorkMovementsCompanion Function({
      required String workId,
      required int seq,
      required String title,
      Value<String?> tempoMark,
      Value<int> rowid,
    });
typedef $$WorkMovementsTableUpdateCompanionBuilder =
    WorkMovementsCompanion Function({
      Value<String> workId,
      Value<int> seq,
      Value<String> title,
      Value<String?> tempoMark,
      Value<int> rowid,
    });

final class $$WorkMovementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkMovementsTable, WorkMovementData> {
  $$WorkMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_movements__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<String>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkMovementsTable> {
  $$WorkMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempoMark => $composableBuilder(
    column: $table.tempoMark,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkMovementsTable> {
  $$WorkMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempoMark => $composableBuilder(
    column: $table.tempoMark,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkMovementsTable> {
  $$WorkMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get tempoMark =>
      $composableBuilder(column: $table.tempoMark, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkMovementsTable,
          WorkMovementData,
          $$WorkMovementsTableFilterComposer,
          $$WorkMovementsTableOrderingComposer,
          $$WorkMovementsTableAnnotationComposer,
          $$WorkMovementsTableCreateCompanionBuilder,
          $$WorkMovementsTableUpdateCompanionBuilder,
          (WorkMovementData, $$WorkMovementsTableReferences),
          WorkMovementData,
          PrefetchHooks Function({bool workId})
        > {
  $$WorkMovementsTableTableManager(_$AppDatabase db, $WorkMovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> tempoMark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkMovementsCompanion(
                workId: workId,
                seq: seq,
                title: title,
                tempoMark: tempoMark,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workId,
                required int seq,
                required String title,
                Value<String?> tempoMark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkMovementsCompanion.insert(
                workId: workId,
                seq: seq,
                title: title,
                tempoMark: tempoMark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workId,
                                referencedTable: $$WorkMovementsTableReferences
                                    ._workIdTable(db),
                                referencedColumn: $$WorkMovementsTableReferences
                                    ._workIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkMovementsTable,
      WorkMovementData,
      $$WorkMovementsTableFilterComposer,
      $$WorkMovementsTableOrderingComposer,
      $$WorkMovementsTableAnnotationComposer,
      $$WorkMovementsTableCreateCompanionBuilder,
      $$WorkMovementsTableUpdateCompanionBuilder,
      (WorkMovementData, $$WorkMovementsTableReferences),
      WorkMovementData,
      PrefetchHooks Function({bool workId})
    >;
typedef $$WorkAliasesTableCreateCompanionBuilder =
    WorkAliasesCompanion Function({
      required String id,
      Value<String?> workId,
      Value<String?> composerKey,
      required String alias,
      Value<String?> language,
      Value<int> rowid,
    });
typedef $$WorkAliasesTableUpdateCompanionBuilder =
    WorkAliasesCompanion Function({
      Value<String> id,
      Value<String?> workId,
      Value<String?> composerKey,
      Value<String> alias,
      Value<String?> language,
      Value<int> rowid,
    });

final class $$WorkAliasesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkAliasesTable, WorkAliasData> {
  $$WorkAliasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_aliases__work_id__works__id');

  $$WorksTableProcessedTableManager? get workId {
    final $_column = $_itemColumn<String>('work_id');
    if ($_column == null) return null;
    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkAliasesTable> {
  $$WorkAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get composerKey => $composableBuilder(
    column: $table.composerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkAliasesTable> {
  $$WorkAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get composerKey => $composableBuilder(
    column: $table.composerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkAliasesTable> {
  $$WorkAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get composerKey => $composableBuilder(
    column: $table.composerKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkAliasesTable,
          WorkAliasData,
          $$WorkAliasesTableFilterComposer,
          $$WorkAliasesTableOrderingComposer,
          $$WorkAliasesTableAnnotationComposer,
          $$WorkAliasesTableCreateCompanionBuilder,
          $$WorkAliasesTableUpdateCompanionBuilder,
          (WorkAliasData, $$WorkAliasesTableReferences),
          WorkAliasData,
          PrefetchHooks Function({bool workId})
        > {
  $$WorkAliasesTableTableManager(_$AppDatabase db, $WorkAliasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<String?> composerKey = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkAliasesCompanion(
                id: id,
                workId: workId,
                composerKey: composerKey,
                alias: alias,
                language: language,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> workId = const Value.absent(),
                Value<String?> composerKey = const Value.absent(),
                required String alias,
                Value<String?> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkAliasesCompanion.insert(
                id: id,
                workId: workId,
                composerKey: composerKey,
                alias: alias,
                language: language,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkAliasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workId,
                                referencedTable: $$WorkAliasesTableReferences
                                    ._workIdTable(db),
                                referencedColumn: $$WorkAliasesTableReferences
                                    ._workIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkAliasesTable,
      WorkAliasData,
      $$WorkAliasesTableFilterComposer,
      $$WorkAliasesTableOrderingComposer,
      $$WorkAliasesTableAnnotationComposer,
      $$WorkAliasesTableCreateCompanionBuilder,
      $$WorkAliasesTableUpdateCompanionBuilder,
      (WorkAliasData, $$WorkAliasesTableReferences),
      WorkAliasData,
      PrefetchHooks Function({bool workId})
    >;
typedef $$CommentariesTableCreateCompanionBuilder =
    CommentariesCompanion Function({
      required String workId,
      required String language,
      required String body,
      Value<int> version,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CommentariesTableUpdateCompanionBuilder =
    CommentariesCompanion Function({
      Value<String> workId,
      Value<String> language,
      Value<String> body,
      Value<int> version,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$CommentariesTableReferences
    extends BaseReferences<_$AppDatabase, $CommentariesTable, CommentaryData> {
  $$CommentariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('commentaries__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<String>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommentariesTableFilterComposer
    extends Composer<_$AppDatabase, $CommentariesTable> {
  $$CommentariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentariesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentariesTable> {
  $$CommentariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentariesTable> {
  $$CommentariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentariesTable,
          CommentaryData,
          $$CommentariesTableFilterComposer,
          $$CommentariesTableOrderingComposer,
          $$CommentariesTableAnnotationComposer,
          $$CommentariesTableCreateCompanionBuilder,
          $$CommentariesTableUpdateCompanionBuilder,
          (CommentaryData, $$CommentariesTableReferences),
          CommentaryData,
          PrefetchHooks Function({bool workId})
        > {
  $$CommentariesTableTableManager(_$AppDatabase db, $CommentariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentariesCompanion(
                workId: workId,
                language: language,
                body: body,
                version: version,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workId,
                required String language,
                required String body,
                Value<int> version = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentariesCompanion.insert(
                workId: workId,
                language: language,
                body: body,
                version: version,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommentariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workId,
                                referencedTable: $$CommentariesTableReferences
                                    ._workIdTable(db),
                                referencedColumn: $$CommentariesTableReferences
                                    ._workIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommentariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentariesTable,
      CommentaryData,
      $$CommentariesTableFilterComposer,
      $$CommentariesTableOrderingComposer,
      $$CommentariesTableAnnotationComposer,
      $$CommentariesTableCreateCompanionBuilder,
      $$CommentariesTableUpdateCompanionBuilder,
      (CommentaryData, $$CommentariesTableReferences),
      CommentaryData,
      PrefetchHooks Function({bool workId})
    >;
typedef $$AlbumsTableCreateCompanionBuilder =
    AlbumsCompanion Function({
      required String id,
      required String userId,
      required String title,
      Value<String?> label,
      Value<int?> releaseYear,
      Value<int> discCount,
      Value<String?> format,
      Value<String?> barcode,
      Value<String?> coverUrl,
      Value<String?> location,
      Value<String?> review,
      Value<DateTime?> acquiredAt,
      Value<DateTime?> disposedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AlbumsTableUpdateCompanionBuilder =
    AlbumsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String?> label,
      Value<int?> releaseYear,
      Value<int> discCount,
      Value<String?> format,
      Value<String?> barcode,
      Value<String?> coverUrl,
      Value<String?> location,
      Value<String?> review,
      Value<DateTime?> acquiredAt,
      Value<DateTime?> disposedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTable, AlbumData> {
  $$AlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompositionsTable, List<CompositionData>>
  _compositionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compositions,
    aliasName: 'albums__id__compositions__album_id',
  );

  $$CompositionsTableProcessedTableManager get compositionsRefs {
    final manager = $$CompositionsTableTableManager(
      $_db,
      $_db.compositions,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_compositionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlbumPerformersTable, List<AlbumPerformerData>>
  _albumPerformersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.albumPerformers,
    aliasName: 'albums__id__album_performers__album_id',
  );

  $$AlbumPerformersTableProcessedTableManager get albumPerformersRefs {
    final manager = $$AlbumPerformersTableTableManager(
      $_db,
      $_db.albumPerformers,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _albumPerformersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WishlistTable, List<WishlistData>>
  _wishlistRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wishlist,
    aliasName: 'albums__id__wishlist__album_id',
  );

  $$WishlistTableProcessedTableManager get wishlistRefs {
    final manager = $$WishlistTableTableManager(
      $_db,
      $_db.wishlist,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wishlistRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discCount => $composableBuilder(
    column: $table.discCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> compositionsRefs(
    Expression<bool> Function($$CompositionsTableFilterComposer f) f,
  ) {
    final $$CompositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableFilterComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> albumPerformersRefs(
    Expression<bool> Function($$AlbumPerformersTableFilterComposer f) f,
  ) {
    final $$AlbumPerformersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPerformers,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPerformersTableFilterComposer(
            $db: $db,
            $table: $db.albumPerformers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wishlistRefs(
    Expression<bool> Function($$WishlistTableFilterComposer f) f,
  ) {
    final $$WishlistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlist,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistTableFilterComposer(
            $db: $db,
            $table: $db.wishlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discCount => $composableBuilder(
    column: $table.discCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discCount =>
      $composableBuilder(column: $table.discCount, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> compositionsRefs<T extends Object>(
    Expression<T> Function($$CompositionsTableAnnotationComposer a) f,
  ) {
    final $$CompositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> albumPerformersRefs<T extends Object>(
    Expression<T> Function($$AlbumPerformersTableAnnotationComposer a) f,
  ) {
    final $$AlbumPerformersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPerformers,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPerformersTableAnnotationComposer(
            $db: $db,
            $table: $db.albumPerformers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wishlistRefs<T extends Object>(
    Expression<T> Function($$WishlistTableAnnotationComposer a) f,
  ) {
    final $$WishlistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlist,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistTableAnnotationComposer(
            $db: $db,
            $table: $db.wishlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTable,
          AlbumData,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (AlbumData, $$AlbumsTableReferences),
          AlbumData,
          PrefetchHooks Function({
            bool compositionsRefs,
            bool albumPerformersRefs,
            bool wishlistRefs,
          })
        > {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<int> discCount = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<DateTime?> disposedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                userId: userId,
                title: title,
                label: label,
                releaseYear: releaseYear,
                discCount: discCount,
                format: format,
                barcode: barcode,
                coverUrl: coverUrl,
                location: location,
                review: review,
                acquiredAt: acquiredAt,
                disposedAt: disposedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                Value<String?> label = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<int> discCount = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<DateTime?> disposedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                label: label,
                releaseYear: releaseYear,
                discCount: discCount,
                format: format,
                barcode: barcode,
                coverUrl: coverUrl,
                location: location,
                review: review,
                acquiredAt: acquiredAt,
                disposedAt: disposedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AlbumsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                compositionsRefs = false,
                albumPerformersRefs = false,
                wishlistRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compositionsRefs) db.compositions,
                    if (albumPerformersRefs) db.albumPerformers,
                    if (wishlistRefs) db.wishlist,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compositionsRefs)
                        await $_getPrefetchedData<
                          AlbumData,
                          $AlbumsTable,
                          CompositionData
                        >(
                          currentTable: table,
                          referencedTable: $$AlbumsTableReferences
                              ._compositionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AlbumsTableReferences(
                                db,
                                table,
                                p0,
                              ).compositionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (albumPerformersRefs)
                        await $_getPrefetchedData<
                          AlbumData,
                          $AlbumsTable,
                          AlbumPerformerData
                        >(
                          currentTable: table,
                          referencedTable: $$AlbumsTableReferences
                              ._albumPerformersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AlbumsTableReferences(
                                db,
                                table,
                                p0,
                              ).albumPerformersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wishlistRefs)
                        await $_getPrefetchedData<
                          AlbumData,
                          $AlbumsTable,
                          WishlistData
                        >(
                          currentTable: table,
                          referencedTable: $$AlbumsTableReferences
                              ._wishlistRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AlbumsTableReferences(
                                db,
                                table,
                                p0,
                              ).wishlistRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTable,
      AlbumData,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (AlbumData, $$AlbumsTableReferences),
      AlbumData,
      PrefetchHooks Function({
        bool compositionsRefs,
        bool albumPerformersRefs,
        bool wishlistRefs,
      })
    >;
typedef $$CompositionsTableCreateCompanionBuilder =
    CompositionsCompanion Function({
      required String id,
      required String userId,
      required String albumId,
      Value<String?> workId,
      Value<String?> title,
      required String composer,
      Value<String?> catalogNumber,
      Value<int?> discNo,
      Value<int?> trackFrom,
      Value<int?> trackTo,
      Value<int> seq,
      Value<String> confidence,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CompositionsTableUpdateCompanionBuilder =
    CompositionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> albumId,
      Value<String?> workId,
      Value<String?> title,
      Value<String> composer,
      Value<String?> catalogNumber,
      Value<int?> discNo,
      Value<int?> trackFrom,
      Value<int?> trackTo,
      Value<int> seq,
      Value<String> confidence,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CompositionsTableReferences
    extends BaseReferences<_$AppDatabase, $CompositionsTable, CompositionData> {
  $$CompositionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('compositions__album_id__albums__id');

  $$AlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('compositions__work_id__works__id');

  $$WorksTableProcessedTableManager? get workId {
    final $_column = $_itemColumn<String>('work_id');
    if ($_column == null) return null;
    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MovementsTable, List<MovementData>>
  _movementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.movements,
    aliasName: 'compositions__id__movements__composition_id',
  );

  $$MovementsTableProcessedTableManager get movementsRefs {
    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.compositionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CompositionPerformersTable,
    List<CompositionPerformerData>
  >
  _compositionPerformersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compositionPerformers,
        aliasName: 'compositions__id__composition_performers__composition_id',
      );

  $$CompositionPerformersTableProcessedTableManager
  get compositionPerformersRefs {
    final manager = $$CompositionPerformersTableTableManager(
      $_db,
      $_db.compositionPerformers,
    ).filter((f) => f.compositionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compositionPerformersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompositionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompositionsTable> {
  $$CompositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get composer => $composableBuilder(
    column: $table.composer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackFrom => $composableBuilder(
    column: $table.trackFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackTo => $composableBuilder(
    column: $table.trackTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> movementsRefs(
    Expression<bool> Function($$MovementsTableFilterComposer f) f,
  ) {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.compositionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compositionPerformersRefs(
    Expression<bool> Function($$CompositionPerformersTableFilterComposer f) f,
  ) {
    final $$CompositionPerformersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositionPerformers,
          getReferencedColumn: (t) => t.compositionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositionPerformersTableFilterComposer(
                $db: $db,
                $table: $db.compositionPerformers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompositionsTable> {
  $$CompositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get composer => $composableBuilder(
    column: $table.composer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackFrom => $composableBuilder(
    column: $table.trackFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackTo => $composableBuilder(
    column: $table.trackTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompositionsTable> {
  $$CompositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get composer =>
      $composableBuilder(column: $table.composer, builder: (column) => column);

  GeneratedColumn<String> get catalogNumber => $composableBuilder(
    column: $table.catalogNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discNo =>
      $composableBuilder(column: $table.discNo, builder: (column) => column);

  GeneratedColumn<int> get trackFrom =>
      $composableBuilder(column: $table.trackFrom, builder: (column) => column);

  GeneratedColumn<int> get trackTo =>
      $composableBuilder(column: $table.trackTo, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> movementsRefs<T extends Object>(
    Expression<T> Function($$MovementsTableAnnotationComposer a) f,
  ) {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.compositionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compositionPerformersRefs<T extends Object>(
    Expression<T> Function($$CompositionPerformersTableAnnotationComposer a) f,
  ) {
    final $$CompositionPerformersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositionPerformers,
          getReferencedColumn: (t) => t.compositionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositionPerformersTableAnnotationComposer(
                $db: $db,
                $table: $db.compositionPerformers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompositionsTable,
          CompositionData,
          $$CompositionsTableFilterComposer,
          $$CompositionsTableOrderingComposer,
          $$CompositionsTableAnnotationComposer,
          $$CompositionsTableCreateCompanionBuilder,
          $$CompositionsTableUpdateCompanionBuilder,
          (CompositionData, $$CompositionsTableReferences),
          CompositionData,
          PrefetchHooks Function({
            bool albumId,
            bool workId,
            bool movementsRefs,
            bool compositionPerformersRefs,
          })
        > {
  $$CompositionsTableTableManager(_$AppDatabase db, $CompositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> composer = const Value.absent(),
                Value<String?> catalogNumber = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> trackFrom = const Value.absent(),
                Value<int?> trackTo = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositionsCompanion(
                id: id,
                userId: userId,
                albumId: albumId,
                workId: workId,
                title: title,
                composer: composer,
                catalogNumber: catalogNumber,
                discNo: discNo,
                trackFrom: trackFrom,
                trackTo: trackTo,
                seq: seq,
                confidence: confidence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String albumId,
                Value<String?> workId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required String composer,
                Value<String?> catalogNumber = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> trackFrom = const Value.absent(),
                Value<int?> trackTo = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositionsCompanion.insert(
                id: id,
                userId: userId,
                albumId: albumId,
                workId: workId,
                title: title,
                composer: composer,
                catalogNumber: catalogNumber,
                discNo: discNo,
                trackFrom: trackFrom,
                trackTo: trackTo,
                seq: seq,
                confidence: confidence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompositionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                albumId = false,
                workId = false,
                movementsRefs = false,
                compositionPerformersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (movementsRefs) db.movements,
                    if (compositionPerformersRefs) db.compositionPerformers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (albumId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.albumId,
                                    referencedTable:
                                        $$CompositionsTableReferences
                                            ._albumIdTable(db),
                                    referencedColumn:
                                        $$CompositionsTableReferences
                                            ._albumIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workId,
                                    referencedTable:
                                        $$CompositionsTableReferences
                                            ._workIdTable(db),
                                    referencedColumn:
                                        $$CompositionsTableReferences
                                            ._workIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (movementsRefs)
                        await $_getPrefetchedData<
                          CompositionData,
                          $CompositionsTable,
                          MovementData
                        >(
                          currentTable: table,
                          referencedTable: $$CompositionsTableReferences
                              ._movementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompositionsTableReferences(
                                db,
                                table,
                                p0,
                              ).movementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compositionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (compositionPerformersRefs)
                        await $_getPrefetchedData<
                          CompositionData,
                          $CompositionsTable,
                          CompositionPerformerData
                        >(
                          currentTable: table,
                          referencedTable: $$CompositionsTableReferences
                              ._compositionPerformersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompositionsTableReferences(
                                db,
                                table,
                                p0,
                              ).compositionPerformersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compositionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompositionsTable,
      CompositionData,
      $$CompositionsTableFilterComposer,
      $$CompositionsTableOrderingComposer,
      $$CompositionsTableAnnotationComposer,
      $$CompositionsTableCreateCompanionBuilder,
      $$CompositionsTableUpdateCompanionBuilder,
      (CompositionData, $$CompositionsTableReferences),
      CompositionData,
      PrefetchHooks Function({
        bool albumId,
        bool workId,
        bool movementsRefs,
        bool compositionPerformersRefs,
      })
    >;
typedef $$MovementsTableCreateCompanionBuilder =
    MovementsCompanion Function({
      required String id,
      required String userId,
      required String compositionId,
      required int seq,
      required String title,
      Value<int?> trackNo,
      Value<int?> durationSec,
      Value<int> rowid,
    });
typedef $$MovementsTableUpdateCompanionBuilder =
    MovementsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> compositionId,
      Value<int> seq,
      Value<String> title,
      Value<int?> trackNo,
      Value<int?> durationSec,
      Value<int> rowid,
    });

final class $$MovementsTableReferences
    extends BaseReferences<_$AppDatabase, $MovementsTable, MovementData> {
  $$MovementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompositionsTable _compositionIdTable(_$AppDatabase db) => db
      .compositions
      .createAlias('movements__composition_id__compositions__id');

  $$CompositionsTableProcessedTableManager get compositionId {
    final $_column = $_itemColumn<String>('composition_id')!;

    final manager = $$CompositionsTableTableManager(
      $_db,
      $_db.compositions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compositionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementsTableFilterComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  $$CompositionsTableFilterComposer get compositionId {
    final $$CompositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableFilterComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompositionsTableOrderingComposer get compositionId {
    final $$CompositionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableOrderingComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get trackNo =>
      $composableBuilder(column: $table.trackNo, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  $$CompositionsTableAnnotationComposer get compositionId {
    final $$CompositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementsTable,
          MovementData,
          $$MovementsTableFilterComposer,
          $$MovementsTableOrderingComposer,
          $$MovementsTableAnnotationComposer,
          $$MovementsTableCreateCompanionBuilder,
          $$MovementsTableUpdateCompanionBuilder,
          (MovementData, $$MovementsTableReferences),
          MovementData,
          PrefetchHooks Function({bool compositionId})
        > {
  $$MovementsTableTableManager(_$AppDatabase db, $MovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> compositionId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion(
                id: id,
                userId: userId,
                compositionId: compositionId,
                seq: seq,
                title: title,
                trackNo: trackNo,
                durationSec: durationSec,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String compositionId,
                required int seq,
                required String title,
                Value<int?> trackNo = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion.insert(
                id: id,
                userId: userId,
                compositionId: compositionId,
                seq: seq,
                title: title,
                trackNo: trackNo,
                durationSec: durationSec,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compositionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compositionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compositionId,
                                referencedTable: $$MovementsTableReferences
                                    ._compositionIdTable(db),
                                referencedColumn: $$MovementsTableReferences
                                    ._compositionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementsTable,
      MovementData,
      $$MovementsTableFilterComposer,
      $$MovementsTableOrderingComposer,
      $$MovementsTableAnnotationComposer,
      $$MovementsTableCreateCompanionBuilder,
      $$MovementsTableUpdateCompanionBuilder,
      (MovementData, $$MovementsTableReferences),
      MovementData,
      PrefetchHooks Function({bool compositionId})
    >;
typedef $$AlbumPerformersTableCreateCompanionBuilder =
    AlbumPerformersCompanion Function({
      required String id,
      required String userId,
      required String albumId,
      required String role,
      required String name,
      Value<int> rowid,
    });
typedef $$AlbumPerformersTableUpdateCompanionBuilder =
    AlbumPerformersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> albumId,
      Value<String> role,
      Value<String> name,
      Value<int> rowid,
    });

final class $$AlbumPerformersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AlbumPerformersTable,
          AlbumPerformerData
        > {
  $$AlbumPerformersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('album_performers__album_id__albums__id');

  $$AlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlbumPerformersTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumPerformersTable> {
  $$AlbumPerformersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPerformersTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumPerformersTable> {
  $$AlbumPerformersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPerformersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumPerformersTable> {
  $$AlbumPerformersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPerformersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumPerformersTable,
          AlbumPerformerData,
          $$AlbumPerformersTableFilterComposer,
          $$AlbumPerformersTableOrderingComposer,
          $$AlbumPerformersTableAnnotationComposer,
          $$AlbumPerformersTableCreateCompanionBuilder,
          $$AlbumPerformersTableUpdateCompanionBuilder,
          (AlbumPerformerData, $$AlbumPerformersTableReferences),
          AlbumPerformerData,
          PrefetchHooks Function({bool albumId})
        > {
  $$AlbumPerformersTableTableManager(
    _$AppDatabase db,
    $AlbumPerformersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumPerformersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumPerformersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumPerformersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumPerformersCompanion(
                id: id,
                userId: userId,
                albumId: albumId,
                role: role,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String albumId,
                required String role,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => AlbumPerformersCompanion.insert(
                id: id,
                userId: userId,
                albumId: albumId,
                role: role,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumPerformersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable:
                                    $$AlbumPerformersTableReferences
                                        ._albumIdTable(db),
                                referencedColumn:
                                    $$AlbumPerformersTableReferences
                                        ._albumIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlbumPerformersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumPerformersTable,
      AlbumPerformerData,
      $$AlbumPerformersTableFilterComposer,
      $$AlbumPerformersTableOrderingComposer,
      $$AlbumPerformersTableAnnotationComposer,
      $$AlbumPerformersTableCreateCompanionBuilder,
      $$AlbumPerformersTableUpdateCompanionBuilder,
      (AlbumPerformerData, $$AlbumPerformersTableReferences),
      AlbumPerformerData,
      PrefetchHooks Function({bool albumId})
    >;
typedef $$CompositionPerformersTableCreateCompanionBuilder =
    CompositionPerformersCompanion Function({
      required String id,
      required String userId,
      required String compositionId,
      required String role,
      required String name,
      Value<int> rowid,
    });
typedef $$CompositionPerformersTableUpdateCompanionBuilder =
    CompositionPerformersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> compositionId,
      Value<String> role,
      Value<String> name,
      Value<int> rowid,
    });

final class $$CompositionPerformersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompositionPerformersTable,
          CompositionPerformerData
        > {
  $$CompositionPerformersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompositionsTable _compositionIdTable(_$AppDatabase db) => db
      .compositions
      .createAlias('composition_performers__composition_id__compositions__id');

  $$CompositionsTableProcessedTableManager get compositionId {
    final $_column = $_itemColumn<String>('composition_id')!;

    final manager = $$CompositionsTableTableManager(
      $_db,
      $_db.compositions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compositionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompositionPerformersTableFilterComposer
    extends Composer<_$AppDatabase, $CompositionPerformersTable> {
  $$CompositionPerformersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CompositionsTableFilterComposer get compositionId {
    final $$CompositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableFilterComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionPerformersTableOrderingComposer
    extends Composer<_$AppDatabase, $CompositionPerformersTable> {
  $$CompositionPerformersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompositionsTableOrderingComposer get compositionId {
    final $$CompositionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableOrderingComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionPerformersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompositionPerformersTable> {
  $$CompositionPerformersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CompositionsTableAnnotationComposer get compositionId {
    final $$CompositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compositionId,
      referencedTable: $db.compositions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.compositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionPerformersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompositionPerformersTable,
          CompositionPerformerData,
          $$CompositionPerformersTableFilterComposer,
          $$CompositionPerformersTableOrderingComposer,
          $$CompositionPerformersTableAnnotationComposer,
          $$CompositionPerformersTableCreateCompanionBuilder,
          $$CompositionPerformersTableUpdateCompanionBuilder,
          (CompositionPerformerData, $$CompositionPerformersTableReferences),
          CompositionPerformerData,
          PrefetchHooks Function({bool compositionId})
        > {
  $$CompositionPerformersTableTableManager(
    _$AppDatabase db,
    $CompositionPerformersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompositionPerformersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CompositionPerformersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CompositionPerformersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> compositionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositionPerformersCompanion(
                id: id,
                userId: userId,
                compositionId: compositionId,
                role: role,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String compositionId,
                required String role,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CompositionPerformersCompanion.insert(
                id: id,
                userId: userId,
                compositionId: compositionId,
                role: role,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompositionPerformersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compositionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compositionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compositionId,
                                referencedTable:
                                    $$CompositionPerformersTableReferences
                                        ._compositionIdTable(db),
                                referencedColumn:
                                    $$CompositionPerformersTableReferences
                                        ._compositionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompositionPerformersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompositionPerformersTable,
      CompositionPerformerData,
      $$CompositionPerformersTableFilterComposer,
      $$CompositionPerformersTableOrderingComposer,
      $$CompositionPerformersTableAnnotationComposer,
      $$CompositionPerformersTableCreateCompanionBuilder,
      $$CompositionPerformersTableUpdateCompanionBuilder,
      (CompositionPerformerData, $$CompositionPerformersTableReferences),
      CompositionPerformerData,
      PrefetchHooks Function({bool compositionId})
    >;
typedef $$WishlistTableCreateCompanionBuilder =
    WishlistCompanion Function({
      required String id,
      required String userId,
      required String type,
      Value<String?> albumId,
      Value<String?> workId,
      Value<int?> priority,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$WishlistTableUpdateCompanionBuilder =
    WishlistCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String?> albumId,
      Value<String?> workId,
      Value<int?> priority,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$WishlistTableReferences
    extends BaseReferences<_$AppDatabase, $WishlistTable, WishlistData> {
  $$WishlistTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('wishlist__album_id__albums__id');

  $$AlbumsTableProcessedTableManager? get albumId {
    final $_column = $_itemColumn<String>('album_id');
    if ($_column == null) return null;
    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('wishlist__work_id__works__id');

  $$WorksTableProcessedTableManager? get workId {
    final $_column = $_itemColumn<String>('work_id');
    if ($_column == null) return null;
    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WishlistTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistTable> {
  $$WishlistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistTable> {
  $$WishlistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistTable> {
  $$WishlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistTable,
          WishlistData,
          $$WishlistTableFilterComposer,
          $$WishlistTableOrderingComposer,
          $$WishlistTableAnnotationComposer,
          $$WishlistTableCreateCompanionBuilder,
          $$WishlistTableUpdateCompanionBuilder,
          (WishlistData, $$WishlistTableReferences),
          WishlistData,
          PrefetchHooks Function({bool albumId, bool workId})
        > {
  $$WishlistTableTableManager(_$AppDatabase db, $WishlistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistCompanion(
                id: id,
                userId: userId,
                type: type,
                albumId: albumId,
                workId: workId,
                priority: priority,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                Value<String?> albumId = const Value.absent(),
                Value<String?> workId = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                albumId: albumId,
                workId: workId,
                priority: priority,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WishlistTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false, workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable: $$WishlistTableReferences
                                    ._albumIdTable(db),
                                referencedColumn: $$WishlistTableReferences
                                    ._albumIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (workId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workId,
                                referencedTable: $$WishlistTableReferences
                                    ._workIdTable(db),
                                referencedColumn: $$WishlistTableReferences
                                    ._workIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WishlistTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistTable,
      WishlistData,
      $$WishlistTableFilterComposer,
      $$WishlistTableOrderingComposer,
      $$WishlistTableAnnotationComposer,
      $$WishlistTableCreateCompanionBuilder,
      $$WishlistTableUpdateCompanionBuilder,
      (WishlistData, $$WishlistTableReferences),
      WishlistData,
      PrefetchHooks Function({bool albumId, bool workId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityTable,
      required String entityId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required String entityId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorksTableTableManager get works =>
      $$WorksTableTableManager(_db, _db.works);
  $$WorkMovementsTableTableManager get workMovements =>
      $$WorkMovementsTableTableManager(_db, _db.workMovements);
  $$WorkAliasesTableTableManager get workAliases =>
      $$WorkAliasesTableTableManager(_db, _db.workAliases);
  $$CommentariesTableTableManager get commentaries =>
      $$CommentariesTableTableManager(_db, _db.commentaries);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$CompositionsTableTableManager get compositions =>
      $$CompositionsTableTableManager(_db, _db.compositions);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
  $$AlbumPerformersTableTableManager get albumPerformers =>
      $$AlbumPerformersTableTableManager(_db, _db.albumPerformers);
  $$CompositionPerformersTableTableManager get compositionPerformers =>
      $$CompositionPerformersTableTableManager(_db, _db.compositionPerformers);
  $$WishlistTableTableManager get wishlist =>
      $$WishlistTableTableManager(_db, _db.wishlist);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
