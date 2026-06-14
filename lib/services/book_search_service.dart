import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

class BookSearchService {
  static const _naverBase = 'https://openapi.naver.com/v1/search';
  static const _googleBase = 'https://www.googleapis.com/books/v1/volumes';

  // 키는 --dart-define-from-file env/dev.json 에서 주입된다.
  static const _naverClientId     = String.fromEnvironment('NAVER_CLIENT_ID');
  static const _naverClientSecret = String.fromEnvironment('NAVER_CLIENT_SECRET');

  Map<String, String> get _naverHeaders => {
        'X-Naver-Client-Id':     _naverClientId,
        'X-Naver-Client-Secret': _naverClientSecret,
      };

  // ── Public: ISBN 검색 (네이버 고급 → Google 폴백) ───────────

  Future<BookSearchResult?> searchByISBN(String isbn) async {
    final clean = isbn.replaceAll(RegExp(r'[\- ]'), '');

    try {
      final result = await _naverByISBN(clean);
      if (result != null) return result;
    } catch (_) {}

    final results = await _searchGoogle('isbn:$clean', maxResults: 1);
    return results.isEmpty ? null : results.first;
  }

  // ── Public: 텍스트 검색 (네이버 → Google 폴백) ──────────────

  Future<List<BookSearchResult>> search(
    String query, {
    int maxResults = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _searchNaver(query, maxResults: maxResults);
      if (results.isNotEmpty) return results;
    } catch (_) {}

    return _searchGoogle(query, maxResults: maxResults);
  }

  // ── Naver: 텍스트 검색 ──────────────────────────────────────

  Future<List<BookSearchResult>> _searchNaver(
    String query, {
    int maxResults = 20,
  }) async {
    final uri = Uri.parse('$_naverBase/book.json').replace(
      queryParameters: {
        'query':   query.trim(),
        'display': '$maxResults',
      },
    );

    final resp = await http
        .get(uri, headers: _naverHeaders)
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('Naver API error (${resp.statusCode})');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = data['items'] as List? ?? [];
    return items
        .map((e) => BookSearchResult.fromNaver(e as Map<String, dynamic>))
        .toList();
  }

  // ── Naver: ISBN 고급 검색 ────────────────────────────────────

  Future<BookSearchResult?> _naverByISBN(String isbn) async {
    final uri = Uri.parse('$_naverBase/book_adv.json').replace(
      queryParameters: {'d_isbn': isbn},
    );

    final resp = await http
        .get(uri, headers: _naverHeaders)
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return null;
    return BookSearchResult.fromNaver(items.first as Map<String, dynamic>);
  }

  // ── Google Books: 폴백 ───────────────────────────────────────

  Future<List<BookSearchResult>> _searchGoogle(
    String query, {
    int maxResults = 20,
  }) async {
    final uri = Uri.parse(_googleBase).replace(queryParameters: {
      'q':          query.trim(),
      'maxResults': '$maxResults',
      'printType':  'books',
      'fields':
          'items(id,volumeInfo(title,authors,publisher,publishedDate,description,industryIdentifiers,pageCount,categories,imageLinks,language))',
    });

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        throw Exception('Google Books error (${resp.statusCode})');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final items = data['items'] as List? ?? [];
      return items
          .map((e) => BookSearchResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('네트워크에 연결할 수 없습니다');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다');
    }
  }
}
