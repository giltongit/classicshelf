// =============================================================================
// barcode_scan_screen.dart — 바코드 스캔 → Discogs 조회 → 등록 폼 프리필 (§4-1)
//
// 이 화면이 흐름 전체를 들고 있다:
//   스캔 → 검색 → (후보 여러 건이면) 선택 → 상세 조회 → /add 로 초안 전달.
//
// 왜 한 화면에 몰았나: 중간 단계(바코드 문자열, 후보 목록)는 저장하지 않는
// 일회성 상태다. 라우트로 쪼개면 그 상태를 라우트 인자로 들고 다녀야 하는데,
// Discogs 응답을 앱 곳곳으로 흘리지 않는 편이 캐시 금지 제약(§ Terms)을
// 지키기도 쉽다. 마지막에 /add로 넘기는 것만 초안(AlbumDraft)이다.
//
// 스캔에 실패하거나 일치하는 음반이 없어도 막다른 길로 두지 않는다 —
// 바코드만 실어 빈 등록 폼으로 보내 수동 입력을 잇는다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/album_draft.dart';
import '../providers/providers.dart';
import '../services/discogs_service.dart';
import '../theme/app_theme.dart';
import 'discogs_match_screen.dart';

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  late final MobileScannerController _controller = MobileScannerController(
    // 음반에 붙는 건 사실상 EAN-13(일부 미국반은 UPC-A)이다. 포맷을 좁히면
    // QR·코드128 같은 걸 잘못 읽고 조회에 실패하는 일이 준다.
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
    // 이미지 바이트는 쓸 데가 없다 — 받아오면 프레임마다 메모리만 먹는다.
    returnImage: false,
  );

  /// 조회 중 중복 인식을 막는다. noDuplicates가 같은 코드의 연속 인식은
  /// 걸러 주지만, 다른 코드가 화면에 들어오면 그대로 통과한다.
  bool _busy = false;

  String? _statusMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 흐름
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;

    final barcode = capture.barcodes.firstWhere(
      (b) => (b.rawValue ?? '').trim().isNotEmpty,
      orElse: () => const Barcode(),
    );
    final code = barcode.rawValue?.trim();
    if (code == null || code.isEmpty) return;

    // 진단 로그 (§17-28). 실패를 "인식 실패 / 포맷 불일치 / 진짜 미보유"로
    // 가르려면 스캐너가 실제로 뭘 읽었는지가 출발점이다.
    //   · len — EAN-13(13)·UPC-A(12)가 아닌 자릿수면 오인식을 의심한다.
    //   · format — 심볼로지. UPC-E(8자리 압축)가 찍히면 12자리로 펴야
    //     Discogs와 맞는데 지금은 그 변환이 없다. 실제로 나오는지 여기서 본다.
    debugPrint('[BARCODE] raw=$code len=${code.length} '
        'format=${barcode.format.name}');

    setState(() {
      _busy = true;
      _statusMessage = '음반 정보를 찾는 중…';
    });
    // 조회하는 동안 카메라를 세운다 — 뒤에서 계속 인식하면 배터리만 쓴다.
    await _controller.stop();

    try {
      await _lookup(code);
    } catch (e) {
      if (!mounted) return;
      final message = e is DiscogsException ? e.message : '조회에 실패했습니다';
      setState(() {
        _busy = false;
        _statusMessage = null;
      });
      // 실패해도 수동 입력으로 이을 수 있게 선택지를 준다.
      final retry = await _askRetry(message, code);
      if (!mounted) return;
      if (retry) {
        await _controller.start();
      }
    }
  }

  Future<void> _lookup(String barcode) async {
    final service = ref.read(discogsServiceProvider);
    final matches = await service.searchByBarcode(barcode);
    if (!mounted) return;

    // 0건 — 바코드만 챙겨 빈 폼으로 보낸다. 사용자가 다시 찍을 필요는 없다.
    if (matches.isEmpty) {
      setState(() => _statusMessage = null);
      final go = await _confirmManualEntry(barcode);
      if (!mounted) return;
      if (go) {
        _openForm(AlbumDraft(barcode: barcode));
      } else {
        setState(() => _busy = false);
        await _controller.start();
      }
      return;
    }

    // 1건 — 고를 게 없으니 바로 상세로 간다.
    var chosen = matches.first;

    // 2건 이상 — 같은 음반의 각국 프레싱이 수십~수백 건 잡히는 게 정상이다.
    // 어느 판인지는 사용자만 알 수 있으므로 고르게 한다.
    if (matches.length > 1) {
      setState(() => _statusMessage = null);
      final picked = await Navigator.of(context).push<DiscogsMatch>(
        MaterialPageRoute(
          builder: (_) => DiscogsMatchScreen(barcode: barcode, matches: matches),
        ),
      );
      if (!mounted) return;
      if (picked == null) {
        // 선택을 취소했다 — 스캔으로 되돌린다.
        setState(() => _busy = false);
        await _controller.start();
        return;
      }
      chosen = picked;
      setState(() => _statusMessage = '음반 정보를 불러오는 중…');
    }

    final draft = await ref.read(discogsServiceProvider).fetchRelease(chosen.id);
    if (!mounted) return;

    // 상세 응답에 바코드가 없는 릴리스가 있다 — 스캔한 값으로 메운다.
    _openForm(draft.barcode == null
        ? AlbumDraft(
            title: draft.title,
            label: draft.label,
            releaseYear: draft.releaseYear,
            discCount: draft.discCount,
            format: draft.format,
            barcode: barcode,
            defaultPerformers: draft.defaultPerformers,
            compositions: draft.compositions,
            sourceName: draft.sourceName,
            sourceUrl: draft.sourceUrl,
          )
        : draft);
  }

  /// 스캔 화면을 등록 폼으로 갈아 끼운다(pushReplacement).
  /// push로 쌓으면 폼에서 뒤로 갔을 때 카메라가 다시 뜨는데, 이미 조회를 마친
  /// 뒤라 사용자가 기대하는 화면이 아니다.
  void _openForm(AlbumDraft draft) {
    context.pushReplacement('/add', extra: draft);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 안내 다이얼로그
  // ───────────────────────────────────────────────────────────────────────────

  Future<bool> _confirmManualEntry(String barcode) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('일치하는 음반을 찾지 못했습니다'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이 바코드로 등록된 음반 정보가 Discogs에 없습니다.',
              style: TextStyle(color: AppColors.cream),
            ),
            const SizedBox(height: 12),
            // 스캔한 원본 값을 그대로 보여 준다(§17-28). 이 값이 있어야
            // 사용자가 discogs.com에서 직접 찾아보고 "정말 없는 건지,
            // 우리가 잘못 읽은 건지"를 스스로 가를 수 있다.
            _ScannedBarcodeBox(barcode: barcode),
            const SizedBox(height: 12),
            const Text(
              '직접 입력해서 등록할 수 있습니다. 바코드는 그대로 저장됩니다.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('다시 스캔'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('직접 입력'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 조회 실패 시. true면 다시 스캔, false면 바코드만 들고 수동 입력으로 간다.
  Future<bool> _askRetry(String message, String barcode) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('조회 실패'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: AppColors.cream)),
            const SizedBox(height: 12),
            // 실패 원인이 네트워크든 뭐든, 읽어낸 값은 보여 준다 —
            // 스캔이 제대로 됐는지부터 사용자가 눈으로 가를 수 있어야 한다.
            _ScannedBarcodeBox(barcode: barcode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('직접 입력'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
    if (result == true) return true;
    if (mounted) _openForm(AlbumDraft(barcode: barcode));
    return false;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('바코드 스캔'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: '플래시',
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (_, state, _) => Icon(
                state.torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: state.torchState == TorchState.on
                    ? AppColors.gold
                    : AppColors.cream,
              ),
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            onDetectError: (error, _) =>
                debugPrint('[SCAN] 인식 오류(무시): $error'),
            errorBuilder: (context, error) => _ScannerError(error: error),
          ),
          const _ScanReticle(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _statusMessage ?? '음반 뒷면의 바코드를 사각형 안에 맞춰 주세요',
                  style: const TextStyle(color: AppColors.cream, fontSize: 13),
                ),
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }
}

/// 스캔한 원본 바코드 표시 + 복사 (§17-28).
///
/// 조회에 실패했을 때 사용자가 쥘 수 있는 단서는 이 값 하나뿐이다.
/// discogs.com에 붙여넣어 직접 검색해 보면 "우리가 잘못 읽었나"와
/// "정말 Discogs에 없나"가 그 자리에서 갈린다.
class _ScannedBarcodeBox extends StatelessWidget {
  final String barcode;

  const _ScannedBarcodeBox({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('스캔한 바코드',
                    style: TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 2),
                SelectableText(
                  barcode,
                  style: const TextStyle(
                    color: AppColors.gold2,
                    fontSize: 16,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '복사',
            icon: const Icon(Icons.copy, size: 18, color: AppColors.muted),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: barcode));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('바코드를 복사했습니다')),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 카메라를 못 열었을 때(권한 거부·기기 미지원). 흰 화면 대신 원인을 보여준다.
class _ScannerError extends StatelessWidget {
  final MobileScannerException error;

  const _ScannerError({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        '카메라 권한이 필요합니다.\n설정에서 권한을 허용해 주세요.',
      MobileScannerErrorCode.unsupported => '이 기기에서는 바코드 스캔을 지원하지 않습니다.',
      _ => '카메라를 열지 못했습니다.\n${error.errorDetails?.message ?? ''}',
    };
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: AppColors.muted, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.cream),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 조준 사각형. 어디에 대야 하는지 알려 주는 것뿐이라 실제 인식 영역과는 무관하다.
class _ScanReticle extends StatelessWidget {
  const _ScanReticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
