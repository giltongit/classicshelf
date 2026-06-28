import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/library_search_result.dart';
import '../services/library_search_service.dart';
import '../theme/app_theme.dart';
import '../utils/region_code.dart';

class UnifiedSearchScreen extends StatefulWidget {
  final String? initialIsbn;

  const UnifiedSearchScreen({
    super.key,
    this.initialIsbn,
  });

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  List<LibrarySearchResult> _libraryResults = [];
  bool _libraryLoading = false;
  String? _libraryError;
  String? _currentIsbn;
  String? _cachedClassNo;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    if (widget.initialIsbn != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchLibraries(isbn: widget.initialIsbn!);
      });
    }
  }

  Future<void> _searchLibraries({required String isbn}) async {
    final clean = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.isEmpty) return;
    setState(() {
      _libraryLoading = true;
      _libraryError = null;
      _libraryResults = [];
      _currentIsbn = clean;
      _cachedClassNo = null;
    });

    if (_userPosition == null) {
      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm != LocationPermission.denied &&
            perm != LocationPermission.deniedForever) {
          _userPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          ).timeout(const Duration(seconds: 5));
        }
      } catch (_) {}
    }

    try {
      String region = '11';
      if (_userPosition != null) {
        region = regionCodeFromLatLng(
              _userPosition!.latitude,
              _userPosition!.longitude,
            ) ??
            '11';
      }

      final results =
          await LibrarySearchService().searchByIsbn(clean, region: region);

      if (_userPosition != null) {
        for (final lib in results) {
          if (lib.lat != null && lib.lng != null) {
            lib.distanceKm = Geolocator.distanceBetween(
              _userPosition!.latitude,
              _userPosition!.longitude,
              lib.lat!,
              lib.lng!,
            ) / 1000;
          }
        }
        results.sort((a, b) {
          if (a.distanceKm == null && b.distanceKm == null) return 0;
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm!.compareTo(b.distanceKm!);
        });
      }

      if (mounted) {
        setState(() {
          _libraryResults = results;
          _libraryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _libraryError = e.toString();
          _libraryLoading = false;
        });
      }
    }
  }

  Future<void> _showLibraryDetailModal({
    required LibrarySearchResult lib,
  }) async {
    if (_cachedClassNo == null && _currentIsbn != null) {
      _cachedClassNo = await LibrarySearchService()
          .getClassNo(_currentIsbn!);
    }

    BookExistResult? existResult;
    try {
      if (_currentIsbn != null) {
        existResult = await LibrarySearchService().checkBookExist(
          libCode: lib.libCode,
          isbn: _currentIsbn!,
        );
      }
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => _LibraryDetailModal(
        lib: lib,
        existResult: existResult,
        classNo: _cachedClassNo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가까운 도서관 검색 결과'),
      ),
      body: _LibrarySearchTab(
        results: _libraryResults,
        loading: _libraryLoading,
        error: _libraryError,
        currentIsbn: _currentIsbn,
        onRetry: () => _searchLibraries(isbn: _currentIsbn ?? ''),
        onLibraryTap: (lib) => _showLibraryDetailModal(lib: lib),
      ),
    );
  }
}

// ── _LibrarySearchTab ───────────────────────────────────────────────────────────

class _LibrarySearchTab extends StatelessWidget {
  final List<LibrarySearchResult> results;
  final bool loading;
  final String? error;
  final String? currentIsbn;
  final VoidCallback onRetry;
  final void Function(LibrarySearchResult) onLibraryTap;

  const _LibrarySearchTab({
    required this.results,
    required this.loading,
    required this.error,
    required this.currentIsbn,
    required this.onRetry,
    required this.onLibraryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 12),
            Text('도서관을 검색하는 중...',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      final msg = currentIsbn != null
          ? '이 지역에 소장한 도서관이 없습니다'
          : '도서 검색에서 [가까운 도서관에서 이 책 찾아보기]를\n눌러 소장 도서관을 찾아보세요';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            msg,
            style: const TextStyle(color: AppColors.muted, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.dim.withValues(alpha: 0.5)),
      itemBuilder: (_, i) => _LibraryResultCard(
        lib: results[i],
        onTap: () => onLibraryTap(results[i]),
      ),
    );
  }
}

// ── _LibraryResultCard ──────────────────────────────────────────────────────────

class _LibraryResultCard extends StatelessWidget {
  final LibrarySearchResult lib;
  final VoidCallback onTap;
  const _LibraryResultCard({required this.lib, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dist = lib.distanceKm;
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading:
          const Icon(Icons.local_library_outlined, color: AppColors.gold),
      title: Text(lib.libName,
          style: const TextStyle(color: AppColors.cream, fontSize: 14)),
      subtitle: Text(
        lib.address,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: dist != null
          ? Text(
              dist < 1
                  ? '${(dist * 1000).round()}m'
                  : '${dist.toStringAsFixed(1)}km',
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 12),
            )
          : null,
    );
  }
}

// ── _LibraryDetailModal ─────────────────────────────────────────────────────────

class _LibraryDetailModal extends StatelessWidget {
  final LibrarySearchResult lib;
  final BookExistResult? existResult;
  final String? classNo;

  const _LibraryDetailModal({
    required this.lib,
    this.existResult,
    this.classNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_library_outlined,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lib.libName,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 8),
            if (lib.address.isNotEmpty)
              _infoRow(Icons.location_on_outlined, lib.address),
            if (lib.tel.isNotEmpty)
              _infoRow(Icons.phone_outlined, lib.tel),
            const SizedBox(height: 8),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 8),
            if (existResult != null) ...[
              _statusRow(
                '소장 여부',
                existResult!.hasBook ? '소장 중' : '미소장',
                existResult!.hasBook ? AppColors.gold : AppColors.muted,
              ),
              const SizedBox(height: 6),
              _statusRow(
                '대출 가능',
                existResult!.loanAvailable ? '가능' : '불가',
                existResult!.loanAvailable
                    ? const Color(0xFF2ECC71)
                    : AppColors.red,
              ),
            ] else
              const Text(
                '소장 정보를 불러오지 못했습니다.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            if (classNo != null && classNo!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _statusRow('한국십진분류기호', classNo!, AppColors.muted),
              const SizedBox(height: 2),
              const Text(
                '도서관에 따라 일치하지 않을 수 있습니다.',
                style: TextStyle(color: AppColors.dim, fontSize: 11),
              ),
            ],
            const SizedBox(height: 16),
            if (lib.lat != null && lib.lng != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('지도 보기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => _openMap(lib.lat!, lib.lng!),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _statusRow(String label, String value, Color valueColor) =>
      Row(
        children: [
          Text('$label  ',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Future<void> _openMap(double lat, double lng) async {
    final kakaoUri = Uri.parse('kakaomap://look?p=$lat,$lng');
    final googleUri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(kakaoUri)) {
      await launchUrl(kakaoUri);
    } else {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }
  }
}
