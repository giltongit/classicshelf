import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeBackgroundNotifier extends AsyncNotifier<String?> {
  static const _fileName = 'home_bg.webp';

  @override
  Future<String?> build() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    return file.existsSync() ? file.path : null;
  }

  Future<void> pickAndSave() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/$_fileName';

    for (final q in [80, 60, 40]) {
      final bytes = await FlutterImageCompress.compressWithFile(
        picked.path,
        format: CompressFormat.webp,
        quality: q,
        minWidth: 1080,
        minHeight: 1920,
      );
      if (bytes == null) break;
      if (bytes.length <= 500 * 1024 || q == 40) {
        await File(destPath).writeAsBytes(bytes);
        state = AsyncData(destPath);
        return;
      }
    }
  }

  Future<void> remove() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (file.existsSync()) file.deleteSync();
    state = const AsyncData(null);
  }
}

final homeBackgroundProvider =
    AsyncNotifierProvider<HomeBackgroundNotifier, String?>(
  HomeBackgroundNotifier.new,
);
