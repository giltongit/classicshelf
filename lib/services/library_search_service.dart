import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/library_search_result.dart';

class BookExistResult {
  final bool hasBook;
  final bool loanAvailable;
  const BookExistResult({
    required this.hasBook,
    required this.loanAvailable,
  });
}

class LibrarySearchService {
  static const _apiKey = String.fromEnvironment('LIBRARY_API_KEY');
  static const _timeout = Duration(seconds: 10);

  Future<List<LibrarySearchResult>> searchByIsbn(
    String isbn, {
    required String region,
  }) async {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[\s\-]'), '');

    final uri = Uri.http('data4library.kr', '/api/libSrchByBook', {
      'authKey':  _apiKey,
      'isbn':     cleanIsbn,
      'region':   region,
      'format':   'json',
      'pageSize': '20',
    });

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('도서관 검색 실패 (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final libs = data['response']?['libs'] as List<dynamic>? ?? [];

    return libs
        .map((e) => LibrarySearchResult.fromJson(
              e['lib'] as Map<String, dynamic>))
        .toList();
  }

  Future<List<LibrarySearchResult>> searchNearby({
    required String region,
    int pageSize = 20,
  }) async {
    final uri = Uri.http('data4library.kr', '/api/libSrch', {
      'authKey':  _apiKey,
      'region':   region,
      'format':   'json',
      'pageSize': pageSize.toString(),
    });

    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('도서관 목록 조회 실패 (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final libs = data['response']?['libs'] as List<dynamic>? ?? [];

    return libs
        .map((e) => LibrarySearchResult.fromJson(
              e['lib'] as Map<String, dynamic>))
        .toList();
  }

  Future<BookExistResult> checkBookExist({
    required String libCode,
    required String isbn,
  }) async {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri.http('data4library.kr', '/api/bookExist', {
      'authKey': _apiKey,
      'libCode': libCode,
      'isbn13':  cleanIsbn,
      'format':  'json',
    });
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('소장 여부 조회 실패 (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result =
        data['response']?['result'] as Map<String, dynamic>? ?? {};
    return BookExistResult(
      hasBook:       (result['hasBook']       as String? ?? 'N') == 'Y',
      loanAvailable: (result['loanAvailable'] as String? ?? 'N') == 'Y',
    );
  }

  Future<String?> getClassNo(String isbn) async {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri.http('data4library.kr', '/api/srchDtlList', {
      'authKey': _apiKey,
      'isbn13':  cleanIsbn,
      'format':  'json',
    });
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = data['response']?['detail'] as List<dynamic>? ?? [];
      if (detail.isEmpty) return null;
      return detail.first['book']?['class_no'] as String?;
    } catch (_) {
      return null;
    }
  }
}
