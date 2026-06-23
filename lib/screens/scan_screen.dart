import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/book_search_result.dart';
import '../services/book_search_service.dart';
import '../theme/app_theme.dart';

/// 스캔 화면의 명시적 상태 머신.
/// 불변식: onDetect는 [_Phase.scanning] 에서만 처리된다.
/// 락(_lastProcessedIsbn) 해제(null)는 "다시 스캔" 버튼([_rescan]) 단 한 곳에서만.
enum _Phase {
  // detect 처리 가능한 유일 상태
  scanning,
  // 처리/이동 중 (detect 무시)
  processing,
  navigatingToAdd, // /add 체류 (검색결과 add · 직접입력 add 공통)
  // resultCard 군 (detect 무시, 카드 표시, 락 유지)
  cardNotFound,
  cardNetworkError,
  cardRateLimited,
  cardCancelled,
  cardError,
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _camera;
  late final AnimationController _sweepCtrl;
  late final Animation<double> _sweepAnim;
  StreamSubscription<BarcodeCapture>? _barcodeSub;

  final _isbnCtrl = TextEditingController();
  _Phase _phase = _Phase.scanning;
  String? _scannedIsbn;
  bool _torchOn = false;
  String? _lastProcessedIsbn; // 앱레벨 dedup: 마지막으로 처리 시작한 ISBN

  @override
  void initState() {
    super.initState();
    // 제약1: autoStart=true(기본)에 기동을 맡긴다. 수동 _camera.start() 금지.
    // 제약2: detectionSpeed 미지정 = DetectionSpeed.normal (noDuplicates 금지).
    _camera = MobileScannerController(
      facing: CameraFacing.back,
    );
    _barcodeSub = _camera.barcodes.listen(_onDetect);
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _sweepAnim = CurvedAnimation(
      parent: _sweepCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // teardown 중 죽은 state로 detect가 들어오지 않도록 구독부터 취소.
    _barcodeSub?.cancel();
    _camera.dispose();
    _sweepCtrl.dispose();
    _isbnCtrl.dispose();
    super.dispose();
  }

  // ── 상태 전이 단일 지점 ────────────────────────────────────
  // 락(_lastProcessedIsbn)은 여기서 건드리지 않는다.
  // 해제는 _rescan, 설정은 _startProcessing 에서만.
  void _to(_Phase next) {
    setState(() => _phase = next);
    if (next == _Phase.scanning) {
      _sweepCtrl.repeat(reverse: true);
    } else {
      _sweepCtrl.stop();
    }
  }

  bool get _isCard => _phase.index >= _Phase.cardNotFound.index;

  String get _cardMessage {
    switch (_phase) {
      case _Phase.cardNotFound:
        return '책을 찾을 수 없습니다';
      case _Phase.cardNetworkError:
        return '네트워크가 연결되어 있지 않습니다';
      case _Phase.cardRateLimited:
        return '검색 한도를 초과했습니다\n잠시 후 다시 시도해 주세요';
      case _Phase.cardCancelled:
        return '저장하지 않았습니다';
      case _Phase.cardError:
        return '일시적인 오류가 발생했습니다';
      default:
        return '';
    }
  }

  String _normalize(String? raw) =>
      raw?.replaceAll(RegExp(r'[^0-9X]'), '') ?? '';

  bool _isValidIsbn(String s) => s.length == 13 || s.length == 10;

  // ── Barcode detected (유일하게 _phase==scanning 에서만 처리) ──
  void _onDetect(BarcodeCapture capture) {
    if (_phase != _Phase.scanning) return; // 단일 가드 (구 _busy 대체)
    final isbn = _normalize(capture.barcodes.firstOrNull?.rawValue);
    if (!_isValidIsbn(isbn)) return; // 책 바코드 아님 → 계속 스캔
    if (isbn == _lastProcessedIsbn) return; // dedup: 같은 책 화면 잔존
    _startProcessing(isbn);
  }

  // 락을 "거는" 유일 지점 (onDetect · 하단바 수동검색 공통).
  void _startProcessing(String isbn) {
    _lastProcessedIsbn = isbn; // 락 ON / 갱신
    _scannedIsbn = isbn;
    _to(_Phase.processing); // sync 전이 → 이후 detect 차단
    _runSearch(isbn); // fire-and-forget
  }

  Future<void> _runSearch(String isbn) async {
    try {
      final result = await BookSearchService().searchByISBN(isbn);
      if (!mounted) return;
      if (result != null) {
        await _goToAdd(result);
      } else {
        _to(_Phase.cardNotFound);
      }
    } on BookSearchRateLimitException {
      if (mounted) _to(_Phase.cardRateLimited);
    } on BookSearchNetworkException {
      if (mounted) _to(_Phase.cardNetworkError);
    } catch (_) {
      if (mounted) _to(_Phase.cardError);
    }
  }

  // 검색결과 add. 저장/취소 모두 락 유지(방금 처리한 책 자동 재검색 차단).
  Future<void> _goToAdd(BookSearchResult result) async {
    _to(_Phase.navigatingToAdd);
    final saved = await context.push<bool>('/add', extra: result);
    if (!mounted) return;
    _to(saved == true ? _Phase.scanning : _Phase.cardCancelled);
  }

  // 직접입력 add. /add 와 동일하게 저장/취소 구분, 둘 다 락 유지.
  Future<void> _goToManualAdd() async {
    _to(_Phase.navigatingToAdd);
    final extra = _lastProcessedIsbn != null
        ? BookSearchResult(
            googleId: '',
            title: '',
            authors: const [],
            categories: const [],
            language: '',
            isbn13: _lastProcessedIsbn!.length == 13 ? _lastProcessedIsbn : null,
            isbn10: _lastProcessedIsbn!.length == 10 ? _lastProcessedIsbn : null,
          )
        : null;
    final saved = await context.push<bool>('/add', extra: extra);
    if (!mounted) return;
    _to(saved == true ? _Phase.scanning : _Phase.cardCancelled);
  }

  // 락을 "푸는" 유일 지점.
  void _rescan() {
    _lastProcessedIsbn = null;
    _scannedIsbn = null;
    _to(_Phase.scanning);
  }

  // 하단 수동 입력바.
  void _manualLookup() {
    if (_phase == _Phase.processing || _phase == _Phase.navigatingToAdd) return;
    final isbn = _normalize(_isbnCtrl.text.trim());
    if (!_isValidIsbn(isbn)) return;
    _startProcessing(isbn);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 제약/요구(d): 어떤 _phase에서도 back은 항상 스캔 화면을 벗어난다(가로채지 않음).
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('ISBN 바코드 스캔',
              style: TextStyle(color: AppColors.gold)),
          actions: [
            IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on : Icons.flash_off,
                color: _torchOn ? AppColors.gold : AppColors.muted,
              ),
              onPressed: () {
                _camera.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.dim),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fw = math.min(constraints.maxWidth * 0.82, 300.0);
                  const fh = 120.0;
                  final fl = (constraints.maxWidth - fw) / 2;
                  final ft = (constraints.maxHeight - fh) / 2 - 32;
                  final frame = Rect.fromLTWH(fl, ft, fw, fh);

                  // 제약3: MobileScanner는 조건 없이 항상 트리에 존재.
                  return Stack(
                    children: [
                      // Camera — 조건부 렌더 없음, 항상 트리 첫 자식
                      MobileScanner(
                        controller: _camera,
                        errorBuilder: (context, error) {
                          // controllerInitializing은 value.error로 오지 않음;
                          // 다른 에러(permissionDenied 등)는 검은 화면 유지.
                          return const ColoredBox(color: Colors.black);
                        },
                      ),

                      // Dark overlay with cutout
                      CustomPaint(
                        size: Size(
                            constraints.maxWidth, constraints.maxHeight),
                        painter: _OverlayPainter(frame: frame),
                      ),

                      // Corner markers
                      ..._corners(frame),

                      // Sweep line (scanning state only)
                      if (_phase == _Phase.scanning)
                        AnimatedBuilder(
                          animation: _sweepAnim,
                          builder: (_, _) => Positioned(
                            left: frame.left + 4,
                            top: frame.top +
                                _sweepAnim.value * (frame.height - 2),
                            width: frame.width - 8,
                            height: 2,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.gold,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Hint text below frame
                      if (_phase == _Phase.scanning)
                        Positioned(
                          top: frame.bottom + 20,
                          left: 0,
                          right: 0,
                          child: const Text(
                            '바코드를 스캔 영역에 맞춰주세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13),
                          ),
                        ),

                      // Processing overlay
                      if (_phase == _Phase.processing)
                        const _ProcessingOverlay(),

                      // Result card (notFound / network / 429 / cancelled / error)
                      if (_isCard)
                        Positioned(
                          top: frame.bottom + 16,
                          left: 24,
                          right: 24,
                          child: _NotFoundCard(
                            isbn: _scannedIsbn,
                            message: _cardMessage,
                            onRetry: _rescan,
                            onManual: _goToManualAdd,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Manual ISBN input bar
            _ManualInputBar(
              controller: _isbnCtrl,
              onSearch: _manualLookup,
              enabled: _phase != _Phase.processing &&
                  _phase != _Phase.navigatingToAdd,
            ),
          ],
        ),
      ),
    );
  }

  // ── Corner markers ────────────────────────────────────────

  List<Widget> _corners(Rect frame) {
    const size = 18.0;
    const thick = 3.0;
    const offset = -1.5;
    const color = AppColors.gold2;

    Widget corner(double left, double top, bool tl, bool tr, bool bl,
        bool br) {
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: tl || tr
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              left: tl || bl
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              right: tr || br
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              bottom: bl || br
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(frame.left + offset,              frame.top + offset,              true,  false, false, false),
      corner(frame.right - size - offset,      frame.top + offset,              false, true,  false, false),
      corner(frame.left + offset,              frame.bottom - size - offset,    false, false, true,  false),
      corner(frame.right - size - offset,      frame.bottom - size - offset,    false, false, false, true),
    ];
  }
}

// ── Overlay painter ───────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final Rect frame;
  const _OverlayPainter({required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
          RRect.fromRectAndRadius(frame, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withAlpha(160));

    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(8)),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.frame != frame;
}

// ── Processing overlay ────────────────────────────────────────

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.gold),
            ),
            SizedBox(height: 16),
            Text('책 정보 검색 중…',
                style: TextStyle(color: AppColors.cream, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Result card (검색실패/네트워크/429/취소/오류 공통) ──────────

class _NotFoundCard extends StatelessWidget {
  final String? isbn;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManual;
  const _NotFoundCard(
      {this.isbn,
      required this.message,
      required this.onRetry,
      required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dim),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.muted, size: 32),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.cream, fontWeight: FontWeight.w600),
          ),
          if (isbn != null) ...[
            const SizedBox(height: 4),
            Text('ISBN: $isbn',
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontFamily: 'monospace')),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('다시 스캔'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.dim),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onManual,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('직접 입력'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Manual input bar ──────────────────────────────────────────

class _ManualInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool enabled;
  const _ManualInputBar(
      {required this.controller,
      required this.onSearch,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.dim)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 14,
                  fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'ISBN 직접 입력 (13자리)',
                hintStyle:
                    TextStyle(color: AppColors.dim, fontSize: 13),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: enabled ? onSearch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              // 전역 테마의 Size.fromHeight(48)(= Size(∞,48))을 덮어써
              // Row 안 unconstrained 너비에서 infinite-width 에러 방지
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('조회'),
          ),
        ],
      ),
    );
  }
}
