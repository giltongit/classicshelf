class BookSearchResult {
  final String googleId;
  final String title;
  final List<String> authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn13;
  final String? isbn10;
  final int? pageCount;
  final List<String> categories;
  final String? thumbnailUrl;
  final String language;

  const BookSearchResult({
    required this.googleId,
    required this.title,
    required this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.isbn13,
    this.isbn10,
    this.pageCount,
    required this.categories,
    this.thumbnailUrl,
    required this.language,
  });

  String get author => authors.join(', ');
  String? get isbn => isbn13 ?? isbn10;
  String? get year => (publishedDate != null && publishedDate!.length >= 4)
      ? publishedDate!.substring(0, 4)
      : null;
  String? get genre => categories.isNotEmpty ? categories.first : null;

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    final info = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};

    String? isbn13;
    String? isbn10;
    for (final id in (info['industryIdentifiers'] as List? ?? [])) {
      if (id['type'] == 'ISBN_13') isbn13 = id['identifier'] as String?;
      if (id['type'] == 'ISBN_10') isbn10 = id['identifier'] as String?;
    }

    final imageLinks = info['imageLinks'] as Map?;
    final rawThumb = imageLinks?['thumbnail'] as String? ??
        imageLinks?['smallThumbnail'] as String?;

    return BookSearchResult(
      googleId: json['id'] as String? ?? '',
      title: info['title'] as String? ?? '(제목 없음)',
      authors: List<String>.from(info['authors'] as List? ?? []),
      publisher: info['publisher'] as String?,
      publishedDate: info['publishedDate'] as String?,
      description: info['description'] as String?,
      isbn13: isbn13,
      isbn10: isbn10,
      pageCount: info['pageCount'] as int?,
      categories: List<String>.from(info['categories'] as List? ?? []),
      thumbnailUrl: _fixUrl(rawThumb),
      language: info['language'] as String? ?? '',
    );
  }

  factory BookSearchResult.fromNaver(Map<String, dynamic> json) {
    // isbn field: "8984053333 9788984053335" (ISBN10 and ISBN13 space-separated)
    final isbnRaw = (json['isbn'] as String? ?? '').trim();
    final isbns = isbnRaw.split(' ').where((s) => s.isNotEmpty).toList();
    final isbn13 = isbns.firstWhere((s) => s.length == 13, orElse: () => '');
    final isbn10 = isbns.firstWhere((s) => s.length == 10, orElse: () => '');

    // author field: "저자1^저자2"
    final authorRaw = (json['author'] as String? ?? '').trim();
    final authors = authorRaw
        .split('^')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // pubdate: "20231201" → "2023"
    final pubdate = (json['pubdate'] as String? ?? '');
    final year = pubdate.length >= 4 ? pubdate.substring(0, 4) : null;

    return BookSearchResult(
      googleId: isbn13.isNotEmpty ? isbn13 : isbn10,
      title: (json['title'] as String? ?? '(제목 없음)').replaceAll(RegExp(r'<[^>]*>'), ''),
      authors: authors.isEmpty ? ['(저자 미상)'] : authors,
      publisher: json['publisher'] as String?,
      publishedDate: year,
      description: (json['description'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), ''),
      isbn13: isbn13.isNotEmpty ? isbn13 : null,
      isbn10: isbn10.isNotEmpty ? isbn10 : null,
      pageCount: null,
      categories: [],
      thumbnailUrl: json['image'] as String?,
      language: 'ko',
    );
  }

  // Google Books returns http:// — upgrade to https and strip curl effect
  static String? _fixUrl(String? url) {
    if (url == null) return null;
    return url
        .replaceFirst('http://', 'https://')
        .replaceAll('&edge=curl', '');
  }
}
