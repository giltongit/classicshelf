import 'dart:convert';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:csv/csv.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import 'auth_service.dart';

// 헤더 → 필드 매핑 결과
class CsvHeaderMap {
  final Map<String, int> columnIndex; // 필드명 → CSV 열 인덱스
  final List<String> unmappedHeaders; // 매핑 안 된 헤더
  const CsvHeaderMap({required this.columnIndex, required this.unmappedHeaders});
}

// 행 단위 import 대상
class ImportRow {
  final int rowNumber;
  final Map<String, String> data; // 필드명 → 값
  final Book? duplicate;          // null이면 신규
  bool selected;                  // 미리보기 체크박스 상태

  ImportRow({
    required this.rowNumber,
    required this.data,
    this.duplicate,
    this.selected = true,
  });

  bool get isNew => duplicate == null;
}

// 실행 결과
class ImportResult {
  final int added;
  final int overwritten;
  final int skipped;
  const ImportResult({
    required this.added,
    required this.overwritten,
    required this.skipped,
  });
}

enum DuplicateAction { skip, overwrite }

class CsvImportService {
  final BookRepository _repo;
  final AuthService _auth;
  CsvImportService(this._repo, this._auth);

  // ── 헤더 키워드 매핑 테이블 ──────────────────────────────
  static const _fieldKeywords = <String, List<String>>{
    'title':      ['title', '제목'],
    'author':     ['author', '저자', '작가'],
    'isbn':       ['isbn'],
    'status':     ['status', '상태'],
    'medium':     ['medium', '매체'],
    'isRead':     ['is_read', '읽음'],
    'publisher':  ['publisher', '출판사'],
    'year':       ['year', '출판연도', '연도'],
    'genre':      ['genre', '장르'],
    'location':   ['location', '위치'],
    'callNumber':   ['call_number', '청구기호'],
    'kdc':          ['kdc'],
    'ddc':          ['ddc'],
    'lc':           ['lc'],
    'language':     ['language', '언어'],
    'priorityRead': ['priority_read', '우선읽기'],
    'description':  ['description', '설명', '책소개'],
    'review':       ['review', '메모'],
    'pageCount':    ['page_count', '페이지'],
    'coverUrl':     ['cover_url', '표지', '표지url'],
    'createdAt':    ['created_at'],
    'updatedAt':    ['updated_at'],
  };

  // ── 인코딩 감지 + CSV 파싱 ───────────────────────────────
  Future<List<List<dynamic>>> parseCsv(Uint8List bytes) async {
    String text;
    try {
      // UTF-8 디코딩 시도
      text = utf8.decode(bytes);
    } catch (_) {
      // 실패 시 CP949(EUC-KR) 폴백
      text = await CharsetConverter.decode('EUC-KR', bytes);
    }
    // BOM 제거
    if (text.startsWith('﻿')) text = text.substring(1);
    return const CsvToListConverter(eol: '\n').convert(text);
  }

  // ── 헤더 자동 매핑 ──────────────────────────────────────
  CsvHeaderMap buildHeaderMap(List<dynamic> headers) {
    final columnIndex = <String, int>{};
    final unmapped = <String>[];

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].toString().trim().toLowerCase();
      String? matched;
      for (final entry in _fieldKeywords.entries) {
        if (entry.value.any((kw) => kw.toLowerCase() == h)) {
          matched = entry.key;
          break;
        }
      }
      if (matched != null) {
        columnIndex[matched] = i;
      } else {
        unmapped.add(headers[i].toString());
      }
    }
    return CsvHeaderMap(columnIndex: columnIndex, unmappedHeaders: unmapped);
  }

  // ── 중복 감지 ────────────────────────────────────────────
  Future<List<ImportRow>> detectDuplicates(
    List<List<dynamic>> rows,
    CsvHeaderMap headerMap,
  ) async {
    final existing = await _repo.getBooks();
    final result = <ImportRow>[];

    // 헤더 행 제외 (index 0)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      final data = <String, String>{};
      headerMap.columnIndex.forEach((field, colIdx) {
        if (colIdx < row.length) {
          data[field] = row[colIdx].toString().trim();
        }
      });

      // title/author 없으면 스킵
      if ((data['title'] ?? '').isEmpty || (data['author'] ?? '').isEmpty) continue;

      // 중복 검사: ISBN 우선 → 제목+저자
      Book? dup;
      final isbn = data['isbn'] ?? '';
      if (isbn.isNotEmpty) {
        dup = existing.where((b) =>
          b.isbn != null && b.isbn!.replaceAll('-', '') == isbn.replaceAll('-', '')
        ).firstOrNull;
      }
      dup ??= existing.where((b) =>
        b.title == data['title'] && b.author == data['author']
      ).firstOrNull;

      result.add(ImportRow(rowNumber: i, data: data, duplicate: dup));
    }
    return result;
  }

  // ── 실행 ─────────────────────────────────────────────────
  Future<ImportResult> executeImport(
    List<ImportRow> rows,
    DuplicateAction duplicateAction,
  ) async {
    int added = 0, overwritten = 0, skipped = 0;

    for (final row in rows) {
      if (!row.selected) { skipped++; continue; }

      if (row.duplicate != null) {
        if (duplicateAction == DuplicateAction.skip) {
          skipped++;
          continue;
        }
        // 덮어쓰기 — 기존 책 id 유지, 필드만 교체
        final updated = _rowToBook(row.data, existingBook: row.duplicate!);
        await _repo.updateBook(updated);
        overwritten++;
      } else {
        final book = _rowToBook(row.data);
        await _repo.addBook(book);
        added++;
      }
    }
    return ImportResult(added: added, overwritten: overwritten, skipped: skipped);
  }

  // ── 행 데이터 → Book 변환 ────────────────────────────────
  Book _rowToBook(Map<String, String> data, {Book? existingBook}) {
    return Book(
      localId: existingBook?.localId,
      supabaseId: existingBook?.supabaseId,
      userId: _auth.currentUserId ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: _nullIfEmpty(_normalizeIsbn(data['isbn'])),
      status: _validStatus(data['status']),
      medium: _validMedium(data['medium']),
      isRead: data['isRead'] == '1' || data['isRead'] == 'true',
      publisher: _nullIfEmpty(data['publisher']),
      year: _nullIfEmpty(data['year']),
      genre: _nullIfEmpty(data['genre']),
      location: _nullIfEmpty(data['location']),
      callNumber: _nullIfEmpty(data['callNumber']),
      kdc: _nullIfEmpty(data['kdc']),
      ddc: _nullIfEmpty(data['ddc']),
      lc:  _nullIfEmpty(data['lc']),
      language: _nullIfEmpty(data['language']),
      priorityRead: _boolVal(data['priorityRead']),
      description: _nullIfEmpty(data['description']),
      review: _nullIfEmpty(data['review']),
      pageCount: int.tryParse(data['pageCount'] ?? ''),
      coverUrl: () {
        final v = _nullIfEmpty(data['coverUrl']);
        if (v == null) return null;
        return (v.startsWith('http://') || v.startsWith('https://')) ? v : null;
      }(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? ''),
    );
  }

  String? _nullIfEmpty(String? s) => (s == null || s.isEmpty) ? null : s;

  // 엑셀 지수 표기(9.79E+12 등) → 정수 문자열. 일반 문자열 ISBN은 그대로.
  String _normalizeIsbn(String? s) {
    if (s == null || s.isEmpty) return s ?? '';
    final n = double.tryParse(s);
    if (n != null) return n.toStringAsFixed(0);
    return s;
  }

  bool _boolVal(String? s) {
    final v = (s ?? '').toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }

  String _validStatus(String? s) {
    const valid = ['owned', 'wishlist', 'rental'];
    return valid.contains(s) ? s! : 'owned';
  }

  String _validMedium(String? s) {
    const valid = ['paper', 'ebook', 'audio'];
    return valid.contains(s) ? s! : 'paper';
  }
}
