import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../repositories/book_repository.dart';

class CsvExportService {
  final BookRepository _repo;
  CsvExportService(this._repo);

  /// 전체 책 목록을 CSV 파일로 저장한다.
  /// 반환값: (path, count, savedDir) — count가 0이면 빈 서가
  Future<({String path, int count, String savedDir})> export() async {
    final books = await _repo.getBooks();
    if (books.isEmpty) return (path: '', count: 0, savedDir: '');

    // 헤더
    final rows = <List<dynamic>>[
      [
        'title', 'author', 'isbn', 'status', 'medium', 'is_read',
        'publisher', 'year', 'genre', 'location', 'call_number',
        'kdc', 'ddc', 'lc',
        'review', 'page_count', 'cover_url', 'created_at', 'updated_at',
        'disposed_at',
      ],
    ];

    // 데이터 행
    for (final b in books) {
      rows.add([
        b.title,
        b.author,
        b.isbn ?? '',
        b.status,          // 'owned' | 'wishlist' | 'rental'
        b.medium,          // 'paper' | 'ebook' | 'audio'
        b.isRead ? '1' : '0',
        b.publisher ?? '',
        b.year ?? '',
        b.genre ?? '',
        b.location ?? '',
        b.callNumber ?? '',
        b.kdc ?? '',
        b.ddc ?? '',
        b.lc  ?? '',
        b.review ?? '',
        b.pageCount?.toString() ?? '',
        b.coverUrl ?? '',
        b.createdAt?.toIso8601String() ?? '',
        b.updatedAt?.toIso8601String() ?? '',
        b.disposedAt?.toIso8601String() ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'mylibrary_$ts.csv';

    String filePath;
    String savedDir;

    if (Platform.isAndroid) {
      const downloadPath = '/storage/emulated/0/Download';
      try {
        final dir = Directory(downloadPath);
        if (!await dir.exists()) await dir.create(recursive: true);
        filePath = '$downloadPath/$fileName';
        savedDir = 'Download';
        debugPrint('[CSV] Download 폴더 저장 시도: $filePath');
      } catch (e) {
        debugPrint('[CSV] Download 폴더 실패, 캐시로 폴백: $e');
        final dir = await getTemporaryDirectory();
        filePath = '${dir.path}/$fileName';
        savedDir = '앱 캐시 (share로 저장해 주세요)';
      }
    } else {
      // TODO: iOS — 샌드박스 제약으로 공용 Download 폴더 직접 쓰기 불가.
      // iOS 출시 시점에 Share Sheet(UIActivityViewController) 경유로 구현.
      // "파일에 저장" 선택 시 iCloud Drive / 로컬 저장 가능.
      final dir = await getTemporaryDirectory();
      filePath = '${dir.path}/$fileName';
      savedDir = '임시 폴더';
    }

    final file = File(filePath);
    await file.writeAsString(csv);

    return (path: file.path, count: books.length, savedDir: savedDir);
  }
}
