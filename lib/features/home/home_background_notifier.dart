import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef HomeBgState = ({List<String?> slotPaths, String? current});

class HomeBackgroundNotifier extends AsyncNotifier<HomeBgState> {
  static const _slotCount = 3;

  static String _fileName(int slot) => 'home_bg_$slot.webp';

  @override
  Future<HomeBgState> build() async {
    final dir = await getApplicationDocumentsDirectory();
    final slotPaths = _readSlots(dir.path);
    final filled = slotPaths.whereType<String>().toList();
    final current =
        filled.isEmpty ? null : filled[Random().nextInt(filled.length)];
    return (slotPaths: slotPaths, current: current);
  }

  // 앱이 foreground로 돌아올 때 호출 — AsyncLoading 없이 즉시 전환
  void reRandomize() {
    final prev = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (prev == null) return;
    final filled = prev.slotPaths.whereType<String>().toList();
    if (filled.isEmpty) return;
    final newCurrent = filled[Random().nextInt(filled.length)];
    state = AsyncData((slotPaths: prev.slotPaths, current: newCurrent));
  }

  Future<void> addOrReplace(int slot) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/${_fileName(slot)}';

    bool written = false;
    for (final q in [80, 60, 40]) {
      final bytes = await FlutterImageCompress.compressWithFile(
        picked.path,
        format: CompressFormat.webp,
        quality: q,
        minWidth: 1080,
      );
      if (bytes == null) break;
      if (bytes.length <= 500 * 1024 || q == 40) {
        await File(destPath).writeAsBytes(bytes);
        written = true;
        break;
      }
    }
    if (!written) return;

    final prev = switch (state) {
      AsyncData(:final value) => value,
      _ => (slotPaths: List<String?>.filled(_slotCount, null), current: null),
    };

    state = AsyncData((
      slotPaths: _readSlots(dir.path),
      current: prev.current ?? destPath,
    ));
  }

  Future<void> remove(int slot) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${_fileName(slot)}';
    final file = File(filePath);
    if (file.existsSync()) file.deleteSync();

    final prev = switch (state) {
      AsyncData(:final value) => value,
      _ => (slotPaths: List<String?>.filled(_slotCount, null), current: null),
    };

    final newSlotPaths = _readSlots(dir.path);
    final filled = newSlotPaths.whereType<String>().toList();

    String? newCurrent = prev.current;
    if (prev.current == filePath) {
      newCurrent =
          filled.isEmpty ? null : filled[Random().nextInt(filled.length)];
    }

    state = AsyncData((slotPaths: newSlotPaths, current: newCurrent));
  }

  List<String?> _readSlots(String dirPath) {
    return List.generate(_slotCount, (i) {
      final file = File('$dirPath/${_fileName(i)}');
      return file.existsSync() ? file.path : null;
    });
  }
}

final homeBackgroundProvider =
    AsyncNotifierProvider<HomeBackgroundNotifier, HomeBgState>(
  HomeBackgroundNotifier.new,
);
