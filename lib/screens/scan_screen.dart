import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/book_search_service.dart';
import '../theme/app_theme.dart';

enum _ScanState { scanning, processing, notFound }

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
  _ScanState _state = _ScanState.scanning;
  String? _scannedIsbn;
  bool _torchOn = false;
  bool _busy = false; // prevents duplicate detections

  @override
  void initState() {
    super.initState();
    _camera = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _barcodeSub = _camera.barcodes.listen(_onDetect);
    unawaited(_camera.start());
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
    _barcodeSub?.cancel();
    _camera.dispose();
    _sweepCtrl.dispose();
    _isbnCtrl.dispose();
    super.dispose();
  }

  // ── Barcode detected ──────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy || _state != _ScanState.scanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    _busy = true;
    await _processISBN(raw);
  }

  Future<void> _processISBN(String raw) async {
    final isbn = raw.replaceAll(RegExp(r'[^0-9X]'), '');
    if (isbn.length != 13 && isbn.length != 10) {
      _busy = false;
      return; // not a book barcode, keep scanning
    }

    await _camera.stop();
    _sweepCtrl.stop();
    setState(() {
      _state = _ScanState.processing;
      _scannedIsbn = isbn;
    });

    try {
      final result = await BookSearchService().searchByISBN(isbn);
      if (!mounted) return;
      if (result != null) {
        // await the push so _reset() runs after user returns from /add
        await context.push('/add', extra: result);
        if (mounted) _reset();
      } else {
        setState(() => _state = _ScanState.notFound);
      }
    } catch (e) {
      if (mounted) setState(() => _state = _ScanState.notFound);
    } finally {
      _busy = false;
    }
  }

  Future<void> _reset() async {
    setState(() {
      _state = _ScanState.scanning;
      _scannedIsbn = null;
    });
    _sweepCtrl.repeat(reverse: true);
    // stop → start clears the noDuplicates detection cache
    await _camera.stop();
    await _camera.start();
  }

  Future<void> _manualLookup() async {
    final isbn = _isbnCtrl.text.trim();
    if (isbn.isEmpty) return;
    await _processISBN(isbn);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final fw =
                    math.min(constraints.maxWidth * 0.82, 300.0);
                const fh = 120.0;
                final fl = (constraints.maxWidth - fw) / 2;
                final ft = (constraints.maxHeight - fh) / 2 - 32;
                final frame = Rect.fromLTWH(fl, ft, fw, fh);

                return Stack(
                  children: [
                    // Camera
                    MobileScanner(
                      controller: _camera,
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
                    if (_state == _ScanState.scanning)
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
                    if (_state == _ScanState.scanning)
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
                    if (_state == _ScanState.processing)
                      const _ProcessingOverlay(),

                    // Not-found card
                    if (_state == _ScanState.notFound)
                      Positioned(
                        top: frame.bottom + 16,
                        left: 24,
                        right: 24,
                        child: _NotFoundCard(
                          isbn: _scannedIsbn,
                          onRetry: _reset,
                          onManual: () => context.push('/add'),
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
            enabled: _state != _ScanState.processing,
          ),
        ],
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

// ── Not found card ────────────────────────────────────────────

class _NotFoundCard extends StatelessWidget {
  final String? isbn;
  final VoidCallback onRetry;
  final VoidCallback onManual;
  const _NotFoundCard(
      {this.isbn, required this.onRetry, required this.onManual});

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
          const Text('책 정보를 찾을 수 없습니다',
              style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600)),
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
