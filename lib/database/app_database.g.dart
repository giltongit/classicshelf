// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _supabaseIdMeta = const VerificationMeta(
    'supabaseId',
  );
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
    'supabase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owned'),
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
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
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
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
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
  static const VerificationMeta _priorityReadMeta = const VerificationMeta(
    'priorityRead',
  );
  @override
  late final GeneratedColumn<bool> priorityRead = GeneratedColumn<bool>(
    'priority_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("priority_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mediumMeta = const VerificationMeta('medium');
  @override
  late final GeneratedColumn<String> medium = GeneratedColumn<String>(
    'medium',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('paper'),
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
  static const VerificationMeta _callNumberMeta = const VerificationMeta(
    'callNumber',
  );
  @override
  late final GeneratedColumn<String> callNumber = GeneratedColumn<String>(
    'call_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kdcMeta = const VerificationMeta('kdc');
  @override
  late final GeneratedColumn<String> kdc = GeneratedColumn<String>(
    'kdc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualKdcMeta = const VerificationMeta(
    'manualKdc',
  );
  @override
  late final GeneratedColumn<String> manualKdc = GeneratedColumn<String>(
    'manual_kdc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ddcMeta = const VerificationMeta('ddc');
  @override
  late final GeneratedColumn<String> ddc = GeneratedColumn<String>(
    'ddc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lcMeta = const VerificationMeta('lc');
  @override
  late final GeneratedColumn<String> lc = GeneratedColumn<String>(
    'lc',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supabaseId,
    userId,
    title,
    author,
    isbn,
    coverUrl,
    description,
    status,
    review,
    pageCount,
    year,
    genre,
    publisher,
    location,
    priorityRead,
    isRead,
    medium,
    language,
    callNumber,
    kdc,
    manualKdc,
    ddc,
    lc,
    acquiredAt,
    createdAt,
    updatedAt,
    disposedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
        _supabaseIdMeta,
        supabaseId.isAcceptableOrUnknown(data['supabase_id']!, _supabaseIdMeta),
      );
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
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('priority_read')) {
      context.handle(
        _priorityReadMeta,
        priorityRead.isAcceptableOrUnknown(
          data['priority_read']!,
          _priorityReadMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('medium')) {
      context.handle(
        _mediumMeta,
        medium.isAcceptableOrUnknown(data['medium']!, _mediumMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('call_number')) {
      context.handle(
        _callNumberMeta,
        callNumber.isAcceptableOrUnknown(data['call_number']!, _callNumberMeta),
      );
    }
    if (data.containsKey('kdc')) {
      context.handle(
        _kdcMeta,
        kdc.isAcceptableOrUnknown(data['kdc']!, _kdcMeta),
      );
    }
    if (data.containsKey('manual_kdc')) {
      context.handle(
        _manualKdcMeta,
        manualKdc.isAcceptableOrUnknown(data['manual_kdc']!, _manualKdcMeta),
      );
    }
    if (data.containsKey('ddc')) {
      context.handle(
        _ddcMeta,
        ddc.isAcceptableOrUnknown(data['ddc']!, _ddcMeta),
      );
    }
    if (data.containsKey('lc')) {
      context.handle(_lcMeta, lc.isAcceptableOrUnknown(data['lc']!, _lcMeta));
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
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
    if (data.containsKey('disposed_at')) {
      context.handle(
        _disposedAtMeta,
        disposedAt.isAcceptableOrUnknown(data['disposed_at']!, _disposedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      supabaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supabase_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      priorityRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}priority_read'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      medium: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medium'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      callNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_number'],
      ),
      kdc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kdc'],
      ),
      manualKdc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_kdc'],
      ),
      ddc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ddc'],
      ),
      lc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lc'],
      ),
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      disposedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}disposed_at'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookData extends DataClass implements Insertable<BookData> {
  final int id;
  final String? supabaseId;
  final String userId;
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final String? description;
  final String status;
  final String? review;
  final int? pageCount;
  final String? year;
  final String? genre;
  final String? publisher;
  final String? location;
  final bool priorityRead;
  final bool isRead;
  final String medium;
  final String? language;
  final String? callNumber;
  final String? kdc;

  /// 드롭다운 장르 추정치(대분류 1자리 또는 중분류 2자리 프리픽스). kdc(정밀 코드)와
  /// 분리해 저장하고, 장르 파생은 effectiveKdc(kdc 우선, 없으면 manualKdc)로 한다
  /// — 추정치가 kdc를 오염시키지 않게 (§26 정정 #29-1).
  final String? manualKdc;
  final String? ddc;
  final String? lc;
  final DateTime? acquiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 처분(판매/기부/분실 등) 시점. null이면 아직 소장 중.
  /// status는 'owned'로 그대로 유지되고, 이 필드만 orthogonal하게 처분 이력을 표시한다
  /// (결정: disposed 상태 A안 — §25).
  final DateTime? disposedAt;
  const BookData({
    required this.id,
    this.supabaseId,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    this.description,
    required this.status,
    this.review,
    this.pageCount,
    this.year,
    this.genre,
    this.publisher,
    this.location,
    required this.priorityRead,
    required this.isRead,
    required this.medium,
    this.language,
    this.callNumber,
    this.kdc,
    this.manualKdc,
    this.ddc,
    this.lc,
    this.acquiredAt,
    required this.createdAt,
    required this.updatedAt,
    this.disposedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['priority_read'] = Variable<bool>(priorityRead);
    map['is_read'] = Variable<bool>(isRead);
    map['medium'] = Variable<String>(medium);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || callNumber != null) {
      map['call_number'] = Variable<String>(callNumber);
    }
    if (!nullToAbsent || kdc != null) {
      map['kdc'] = Variable<String>(kdc);
    }
    if (!nullToAbsent || manualKdc != null) {
      map['manual_kdc'] = Variable<String>(manualKdc);
    }
    if (!nullToAbsent || ddc != null) {
      map['ddc'] = Variable<String>(ddc);
    }
    if (!nullToAbsent || lc != null) {
      map['lc'] = Variable<String>(lc);
    }
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || disposedAt != null) {
      map['disposed_at'] = Variable<DateTime>(disposedAt);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      userId: Value(userId),
      title: Value(title),
      author: Value(author),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      priorityRead: Value(priorityRead),
      isRead: Value(isRead),
      medium: Value(medium),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      callNumber: callNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(callNumber),
      kdc: kdc == null && nullToAbsent ? const Value.absent() : Value(kdc),
      manualKdc: manualKdc == null && nullToAbsent
          ? const Value.absent()
          : Value(manualKdc),
      ddc: ddc == null && nullToAbsent ? const Value.absent() : Value(ddc),
      lc: lc == null && nullToAbsent ? const Value.absent() : Value(lc),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      disposedAt: disposedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disposedAt),
    );
  }

  factory BookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookData(
      id: serializer.fromJson<int>(json['id']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      review: serializer.fromJson<String?>(json['review']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      year: serializer.fromJson<String?>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      location: serializer.fromJson<String?>(json['location']),
      priorityRead: serializer.fromJson<bool>(json['priorityRead']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      medium: serializer.fromJson<String>(json['medium']),
      language: serializer.fromJson<String?>(json['language']),
      callNumber: serializer.fromJson<String?>(json['callNumber']),
      kdc: serializer.fromJson<String?>(json['kdc']),
      manualKdc: serializer.fromJson<String?>(json['manualKdc']),
      ddc: serializer.fromJson<String?>(json['ddc']),
      lc: serializer.fromJson<String?>(json['lc']),
      acquiredAt: serializer.fromJson<DateTime?>(json['acquiredAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      disposedAt: serializer.fromJson<DateTime?>(json['disposedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'isbn': serializer.toJson<String?>(isbn),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'review': serializer.toJson<String?>(review),
      'pageCount': serializer.toJson<int?>(pageCount),
      'year': serializer.toJson<String?>(year),
      'genre': serializer.toJson<String?>(genre),
      'publisher': serializer.toJson<String?>(publisher),
      'location': serializer.toJson<String?>(location),
      'priorityRead': serializer.toJson<bool>(priorityRead),
      'isRead': serializer.toJson<bool>(isRead),
      'medium': serializer.toJson<String>(medium),
      'language': serializer.toJson<String?>(language),
      'callNumber': serializer.toJson<String?>(callNumber),
      'kdc': serializer.toJson<String?>(kdc),
      'manualKdc': serializer.toJson<String?>(manualKdc),
      'ddc': serializer.toJson<String?>(ddc),
      'lc': serializer.toJson<String?>(lc),
      'acquiredAt': serializer.toJson<DateTime?>(acquiredAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'disposedAt': serializer.toJson<DateTime?>(disposedAt),
    };
  }

  BookData copyWith({
    int? id,
    Value<String?> supabaseId = const Value.absent(),
    String? userId,
    String? title,
    String? author,
    Value<String?> isbn = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? status,
    Value<String?> review = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> year = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<String?> location = const Value.absent(),
    bool? priorityRead,
    bool? isRead,
    String? medium,
    Value<String?> language = const Value.absent(),
    Value<String?> callNumber = const Value.absent(),
    Value<String?> kdc = const Value.absent(),
    Value<String?> manualKdc = const Value.absent(),
    Value<String?> ddc = const Value.absent(),
    Value<String?> lc = const Value.absent(),
    Value<DateTime?> acquiredAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> disposedAt = const Value.absent(),
  }) => BookData(
    id: id ?? this.id,
    supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    author: author ?? this.author,
    isbn: isbn.present ? isbn.value : this.isbn,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    review: review.present ? review.value : this.review,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    year: year.present ? year.value : this.year,
    genre: genre.present ? genre.value : this.genre,
    publisher: publisher.present ? publisher.value : this.publisher,
    location: location.present ? location.value : this.location,
    priorityRead: priorityRead ?? this.priorityRead,
    isRead: isRead ?? this.isRead,
    medium: medium ?? this.medium,
    language: language.present ? language.value : this.language,
    callNumber: callNumber.present ? callNumber.value : this.callNumber,
    kdc: kdc.present ? kdc.value : this.kdc,
    manualKdc: manualKdc.present ? manualKdc.value : this.manualKdc,
    ddc: ddc.present ? ddc.value : this.ddc,
    lc: lc.present ? lc.value : this.lc,
    acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    disposedAt: disposedAt.present ? disposedAt.value : this.disposedAt,
  );
  BookData copyWithCompanion(BooksCompanion data) {
    return BookData(
      id: data.id.present ? data.id.value : this.id,
      supabaseId: data.supabaseId.present
          ? data.supabaseId.value
          : this.supabaseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      review: data.review.present ? data.review.value : this.review,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      location: data.location.present ? data.location.value : this.location,
      priorityRead: data.priorityRead.present
          ? data.priorityRead.value
          : this.priorityRead,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      medium: data.medium.present ? data.medium.value : this.medium,
      language: data.language.present ? data.language.value : this.language,
      callNumber: data.callNumber.present
          ? data.callNumber.value
          : this.callNumber,
      kdc: data.kdc.present ? data.kdc.value : this.kdc,
      manualKdc: data.manualKdc.present ? data.manualKdc.value : this.manualKdc,
      ddc: data.ddc.present ? data.ddc.value : this.ddc,
      lc: data.lc.present ? data.lc.value : this.lc,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      disposedAt: data.disposedAt.present
          ? data.disposedAt.value
          : this.disposedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookData(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('review: $review, ')
          ..write('pageCount: $pageCount, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('publisher: $publisher, ')
          ..write('location: $location, ')
          ..write('priorityRead: $priorityRead, ')
          ..write('isRead: $isRead, ')
          ..write('medium: $medium, ')
          ..write('language: $language, ')
          ..write('callNumber: $callNumber, ')
          ..write('kdc: $kdc, ')
          ..write('manualKdc: $manualKdc, ')
          ..write('ddc: $ddc, ')
          ..write('lc: $lc, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('disposedAt: $disposedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    supabaseId,
    userId,
    title,
    author,
    isbn,
    coverUrl,
    description,
    status,
    review,
    pageCount,
    year,
    genre,
    publisher,
    location,
    priorityRead,
    isRead,
    medium,
    language,
    callNumber,
    kdc,
    manualKdc,
    ddc,
    lc,
    acquiredAt,
    createdAt,
    updatedAt,
    disposedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookData &&
          other.id == this.id &&
          other.supabaseId == this.supabaseId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.author == this.author &&
          other.isbn == this.isbn &&
          other.coverUrl == this.coverUrl &&
          other.description == this.description &&
          other.status == this.status &&
          other.review == this.review &&
          other.pageCount == this.pageCount &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.publisher == this.publisher &&
          other.location == this.location &&
          other.priorityRead == this.priorityRead &&
          other.isRead == this.isRead &&
          other.medium == this.medium &&
          other.language == this.language &&
          other.callNumber == this.callNumber &&
          other.kdc == this.kdc &&
          other.manualKdc == this.manualKdc &&
          other.ddc == this.ddc &&
          other.lc == this.lc &&
          other.acquiredAt == this.acquiredAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.disposedAt == this.disposedAt);
}

class BooksCompanion extends UpdateCompanion<BookData> {
  final Value<int> id;
  final Value<String?> supabaseId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> isbn;
  final Value<String?> coverUrl;
  final Value<String?> description;
  final Value<String> status;
  final Value<String?> review;
  final Value<int?> pageCount;
  final Value<String?> year;
  final Value<String?> genre;
  final Value<String?> publisher;
  final Value<String?> location;
  final Value<bool> priorityRead;
  final Value<bool> isRead;
  final Value<String> medium;
  final Value<String?> language;
  final Value<String?> callNumber;
  final Value<String?> kdc;
  final Value<String?> manualKdc;
  final Value<String?> ddc;
  final Value<String?> lc;
  final Value<DateTime?> acquiredAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> disposedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.review = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.publisher = const Value.absent(),
    this.location = const Value.absent(),
    this.priorityRead = const Value.absent(),
    this.isRead = const Value.absent(),
    this.medium = const Value.absent(),
    this.language = const Value.absent(),
    this.callNumber = const Value.absent(),
    this.kdc = const Value.absent(),
    this.manualKdc = const Value.absent(),
    this.ddc = const Value.absent(),
    this.lc = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.disposedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    this.supabaseId = const Value.absent(),
    required String userId,
    required String title,
    required String author,
    this.isbn = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.review = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.publisher = const Value.absent(),
    this.location = const Value.absent(),
    this.priorityRead = const Value.absent(),
    this.isRead = const Value.absent(),
    this.medium = const Value.absent(),
    this.language = const Value.absent(),
    this.callNumber = const Value.absent(),
    this.kdc = const Value.absent(),
    this.manualKdc = const Value.absent(),
    this.ddc = const Value.absent(),
    this.lc = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.disposedAt = const Value.absent(),
  }) : userId = Value(userId),
       title = Value(title),
       author = Value(author);
  static Insertable<BookData> custom({
    Expression<int>? id,
    Expression<String>? supabaseId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? isbn,
    Expression<String>? coverUrl,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? review,
    Expression<int>? pageCount,
    Expression<String>? year,
    Expression<String>? genre,
    Expression<String>? publisher,
    Expression<String>? location,
    Expression<bool>? priorityRead,
    Expression<bool>? isRead,
    Expression<String>? medium,
    Expression<String>? language,
    Expression<String>? callNumber,
    Expression<String>? kdc,
    Expression<String>? manualKdc,
    Expression<String>? ddc,
    Expression<String>? lc,
    Expression<DateTime>? acquiredAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? disposedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (review != null) 'review': review,
      if (pageCount != null) 'page_count': pageCount,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (publisher != null) 'publisher': publisher,
      if (location != null) 'location': location,
      if (priorityRead != null) 'priority_read': priorityRead,
      if (isRead != null) 'is_read': isRead,
      if (medium != null) 'medium': medium,
      if (language != null) 'language': language,
      if (callNumber != null) 'call_number': callNumber,
      if (kdc != null) 'kdc': kdc,
      if (manualKdc != null) 'manual_kdc': manualKdc,
      if (ddc != null) 'ddc': ddc,
      if (lc != null) 'lc': lc,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (disposedAt != null) 'disposed_at': disposedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String?>? supabaseId,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? author,
    Value<String?>? isbn,
    Value<String?>? coverUrl,
    Value<String?>? description,
    Value<String>? status,
    Value<String?>? review,
    Value<int?>? pageCount,
    Value<String?>? year,
    Value<String?>? genre,
    Value<String?>? publisher,
    Value<String?>? location,
    Value<bool>? priorityRead,
    Value<bool>? isRead,
    Value<String>? medium,
    Value<String?>? language,
    Value<String?>? callNumber,
    Value<String?>? kdc,
    Value<String?>? manualKdc,
    Value<String?>? ddc,
    Value<String?>? lc,
    Value<DateTime?>? acquiredAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? disposedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      review: review ?? this.review,
      pageCount: pageCount ?? this.pageCount,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      publisher: publisher ?? this.publisher,
      location: location ?? this.location,
      priorityRead: priorityRead ?? this.priorityRead,
      isRead: isRead ?? this.isRead,
      medium: medium ?? this.medium,
      language: language ?? this.language,
      callNumber: callNumber ?? this.callNumber,
      kdc: kdc ?? this.kdc,
      manualKdc: manualKdc ?? this.manualKdc,
      ddc: ddc ?? this.ddc,
      lc: lc ?? this.lc,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disposedAt: disposedAt ?? this.disposedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (priorityRead.present) {
      map['priority_read'] = Variable<bool>(priorityRead.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (medium.present) {
      map['medium'] = Variable<String>(medium.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (callNumber.present) {
      map['call_number'] = Variable<String>(callNumber.value);
    }
    if (kdc.present) {
      map['kdc'] = Variable<String>(kdc.value);
    }
    if (manualKdc.present) {
      map['manual_kdc'] = Variable<String>(manualKdc.value);
    }
    if (ddc.present) {
      map['ddc'] = Variable<String>(ddc.value);
    }
    if (lc.present) {
      map['lc'] = Variable<String>(lc.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (disposedAt.present) {
      map['disposed_at'] = Variable<DateTime>(disposedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('review: $review, ')
          ..write('pageCount: $pageCount, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('publisher: $publisher, ')
          ..write('location: $location, ')
          ..write('priorityRead: $priorityRead, ')
          ..write('isRead: $isRead, ')
          ..write('medium: $medium, ')
          ..write('language: $language, ')
          ..write('callNumber: $callNumber, ')
          ..write('kdc: $kdc, ')
          ..write('manualKdc: $manualKdc, ')
          ..write('ddc: $ddc, ')
          ..write('lc: $lc, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('disposedAt: $disposedAt')
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
  static const VerificationMeta _localBookIdMeta = const VerificationMeta(
    'localBookId',
  );
  @override
  late final GeneratedColumn<int> localBookId = GeneratedColumn<int>(
    'local_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    localBookId,
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
    if (data.containsKey('local_book_id')) {
      context.handle(
        _localBookIdMeta,
        localBookId.isAcceptableOrUnknown(
          data['local_book_id']!,
          _localBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localBookIdMeta);
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
      localBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_book_id'],
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
  final int localBookId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  const SyncQueueData({
    required this.id,
    required this.localBookId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_book_id'] = Variable<int>(localBookId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      localBookId: Value(localBookId),
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
      localBookId: serializer.fromJson<int>(json['localBookId']),
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
      'localBookId': serializer.toJson<int>(localBookId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    int? localBookId,
    String? operation,
    String? payload,
    DateTime? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    localBookId: localBookId ?? this.localBookId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      localBookId: data.localBookId.present
          ? data.localBookId.value
          : this.localBookId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('localBookId: $localBookId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localBookId, operation, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.localBookId == this.localBookId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<int> localBookId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.localBookId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required int localBookId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : localBookId = Value(localBookId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<int>? localBookId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localBookId != null) 'local_book_id': localBookId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<int>? localBookId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      localBookId: localBookId ?? this.localBookId,
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
    if (localBookId.present) {
      map['local_book_id'] = Variable<int>(localBookId.value);
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
          ..write('localBookId: $localBookId, ')
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
  late final $BooksTable books = $BooksTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books, syncQueue];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String?> supabaseId,
      required String userId,
      required String title,
      required String author,
      Value<String?> isbn,
      Value<String?> coverUrl,
      Value<String?> description,
      Value<String> status,
      Value<String?> review,
      Value<int?> pageCount,
      Value<String?> year,
      Value<String?> genre,
      Value<String?> publisher,
      Value<String?> location,
      Value<bool> priorityRead,
      Value<bool> isRead,
      Value<String> medium,
      Value<String?> language,
      Value<String?> callNumber,
      Value<String?> kdc,
      Value<String?> manualKdc,
      Value<String?> ddc,
      Value<String?> lc,
      Value<DateTime?> acquiredAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> disposedAt,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String?> supabaseId,
      Value<String> userId,
      Value<String> title,
      Value<String> author,
      Value<String?> isbn,
      Value<String?> coverUrl,
      Value<String?> description,
      Value<String> status,
      Value<String?> review,
      Value<int?> pageCount,
      Value<String?> year,
      Value<String?> genre,
      Value<String?> publisher,
      Value<String?> location,
      Value<bool> priorityRead,
      Value<bool> isRead,
      Value<String> medium,
      Value<String?> language,
      Value<String?> callNumber,
      Value<String?> kdc,
      Value<String?> manualKdc,
      Value<String?> ddc,
      Value<String?> lc,
      Value<DateTime?> acquiredAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> disposedAt,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
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

  ColumnFilters<String> get supabaseId => $composableBuilder(
    column: $table.supabaseId,
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

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get priorityRead => $composableBuilder(
    column: $table.priorityRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callNumber => $composableBuilder(
    column: $table.callNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kdc => $composableBuilder(
    column: $table.kdc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualKdc => $composableBuilder(
    column: $table.manualKdc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ddc => $composableBuilder(
    column: $table.ddc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lc => $composableBuilder(
    column: $table.lc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
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

  ColumnFilters<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
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

  ColumnOrderings<String> get supabaseId => $composableBuilder(
    column: $table.supabaseId,
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

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get priorityRead => $composableBuilder(
    column: $table.priorityRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callNumber => $composableBuilder(
    column: $table.callNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kdc => $composableBuilder(
    column: $table.kdc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualKdc => $composableBuilder(
    column: $table.manualKdc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ddc => $composableBuilder(
    column: $table.ddc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lc => $composableBuilder(
    column: $table.lc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
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

  ColumnOrderings<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supabaseId => $composableBuilder(
    column: $table.supabaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get priorityRead => $composableBuilder(
    column: $table.priorityRead,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get medium =>
      $composableBuilder(column: $table.medium, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get callNumber => $composableBuilder(
    column: $table.callNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kdc =>
      $composableBuilder(column: $table.kdc, builder: (column) => column);

  GeneratedColumn<String> get manualKdc =>
      $composableBuilder(column: $table.manualKdc, builder: (column) => column);

  GeneratedColumn<String> get ddc =>
      $composableBuilder(column: $table.ddc, builder: (column) => column);

  GeneratedColumn<String> get lc =>
      $composableBuilder(column: $table.lc, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get disposedAt => $composableBuilder(
    column: $table.disposedAt,
    builder: (column) => column,
  );
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookData,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookData, BaseReferences<_$AppDatabase, $BooksTable, BookData>),
          BookData,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> supabaseId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> priorityRead = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String> medium = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> callNumber = const Value.absent(),
                Value<String?> kdc = const Value.absent(),
                Value<String?> manualKdc = const Value.absent(),
                Value<String?> ddc = const Value.absent(),
                Value<String?> lc = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> disposedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                supabaseId: supabaseId,
                userId: userId,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                description: description,
                status: status,
                review: review,
                pageCount: pageCount,
                year: year,
                genre: genre,
                publisher: publisher,
                location: location,
                priorityRead: priorityRead,
                isRead: isRead,
                medium: medium,
                language: language,
                callNumber: callNumber,
                kdc: kdc,
                manualKdc: manualKdc,
                ddc: ddc,
                lc: lc,
                acquiredAt: acquiredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                disposedAt: disposedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> supabaseId = const Value.absent(),
                required String userId,
                required String title,
                required String author,
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> priorityRead = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String> medium = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> callNumber = const Value.absent(),
                Value<String?> kdc = const Value.absent(),
                Value<String?> manualKdc = const Value.absent(),
                Value<String?> ddc = const Value.absent(),
                Value<String?> lc = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> disposedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                supabaseId: supabaseId,
                userId: userId,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                description: description,
                status: status,
                review: review,
                pageCount: pageCount,
                year: year,
                genre: genre,
                publisher: publisher,
                location: location,
                priorityRead: priorityRead,
                isRead: isRead,
                medium: medium,
                language: language,
                callNumber: callNumber,
                kdc: kdc,
                manualKdc: manualKdc,
                ddc: ddc,
                lc: lc,
                acquiredAt: acquiredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                disposedAt: disposedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookData,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookData, BaseReferences<_$AppDatabase, $BooksTable, BookData>),
      BookData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required int localBookId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<int> localBookId,
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

  ColumnFilters<int> get localBookId => $composableBuilder(
    column: $table.localBookId,
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

  ColumnOrderings<int> get localBookId => $composableBuilder(
    column: $table.localBookId,
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

  GeneratedColumn<int> get localBookId => $composableBuilder(
    column: $table.localBookId,
    builder: (column) => column,
  );

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
                Value<int> localBookId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                localBookId: localBookId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int localBookId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                localBookId: localBookId,
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
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
