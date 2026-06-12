import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage 표지 업로드 서비스.
///
/// 경로 규칙: covers/{userId}/{bookId}.jpg
/// upsert: true → 동일 book_id로 재촬영 시 덮어쓰기.
///   → 펜딩 큐에서 같은 book_id 항목이 중복 적재되더라도
///     마지막 업로드가 최종본이 되므로 파일명 충돌 문제 자연 해소.
///
/// 외부 표지(네이버/구글 북스 URL)는 이 서비스를 거치지 않음.
/// Book.coverUrl에 외부 URL을 직접 저장하면 됨.
class CoverUploadService {
  SupabaseStorageClient get _storage => Supabase.instance.client.storage;

  /// [file]을 Storage에 업로드하고 public URL을 반환.
  Future<String> upload({
    required File file,
    required String userId,
    required String bookId,
  }) async {
    // from('covers') 가 버킷을 지정하므로 path 에는 버킷명 불포함
    final path = '$userId/$bookId.jpg';
    final fileSize = await file.length();
    debugPrint('[COVER] upload 진입 — bucket: covers, path: $path, size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

    try {
      await _storage.from('covers').upload(
        path,
        file,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );
    } catch (e, st) {
      debugPrint('[COVER] storage.upload 예외: $e\n$st');
      rethrow;
    }

    final url = _storage.from('covers').getPublicUrl(path);
    debugPrint('[COVER] Storage 업로드 완료: $url');
    return url;
  }
}
