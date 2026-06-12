import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 카메라/갤러리 촬영 → 리사이즈 → 앱 캐시 저장.
/// 업로드 단계는 CoverUploadService/CoverUploadProvider가 담당.
class CoverPhotoService {
  final _picker = ImagePicker();

  Future<File?> pickFromCamera() => _pick(ImageSource.camera);
  Future<File?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<File?> _pick(ImageSource source) async {
    debugPrint('[COVER] _pick 호출: $source');
    try {
      final xFile = await _picker.pickImage(source: source);
      if (xFile == null) {
        debugPrint('[COVER] 사진 선택 취소 (xFile == null)');
        return null;
      }
      debugPrint('[COVER] 사진 선택 완료: ${xFile.path}');
      return File(xFile.path);
    } catch (e, st) {
      debugPrint('[COVER] _pick 예외: $e\n$st');
      rethrow;
    }
  }

  /// 리사이즈 후 캐시 디렉토리에 저장.
  /// bookId를 파일명으로 사용 → 동일 책 재촬영 시 캐시도 자연 덮어쓰기.
  Future<File> resizeAndCache(File source, String bookId) async {
    final dir = await getTemporaryDirectory();
    debugPrint('[COVER] tmpDir: ${dir.path}');
    final cacheDir = Directory('${dir.path}/covers');
    await cacheDir.create(recursive: true);
    final outPath = '${cacheDir.path}/$bookId.jpg';

    debugPrint('[COVER] 리사이즈 시작: ${source.absolute.path} → $outPath');

    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        outPath,
        minWidth: 600,
        minHeight: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      debugPrint('[COVER] compressAndGetFile 반환: ${result?.path ?? 'null'}');

      if (result == null) {
        throw Exception('compressAndGetFile returned null. outPath=$outPath');
      }

      final size = await File(result.path).length();
      debugPrint('[COVER] 리사이즈 완료: ${(size / 1024).toStringAsFixed(1)} KB');
      return File(result.path);
    } catch (e, st) {
      debugPrint('[COVER] resizeAndCache 예외: $e\n$st');
      rethrow;
    }
  }
}
