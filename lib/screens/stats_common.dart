import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ── 공유 상수 ──────────────────────────────────────────────────────────────────

const yearBucketOrder = [
  '~1979', '1980-1985', '1986-1990', '1991-1995', '1996-2000',
  '2001-2005', '2006-2010', '2011-2015', '2016-2020', '2021-2025',
  '2026~', '미상',
];

const langNames = {
  'ko': '한국어',
  'en': '영어',
  'ja': '일본어',
  'zh': '중국어',
  'fr': '프랑스어',
  'de': '독일어',
  'es': '스페인어',
};

// ── 공유 함수 ──────────────────────────────────────────────────────────────────

String yearBucket(String? year) {
  if (year == null || year.isEmpty) return '미상';
  final y = int.tryParse(year.trim());
  if (y == null) return '미상';
  if (y <= 1979) return '~1979';
  if (y <= 1985) return '1980-1985';
  if (y <= 1990) return '1986-1990';
  if (y <= 1995) return '1991-1995';
  if (y <= 2000) return '1996-2000';
  if (y <= 2005) return '2001-2005';
  if (y <= 2010) return '2006-2010';
  if (y <= 2015) return '2011-2015';
  if (y <= 2020) return '2016-2020';
  if (y <= 2025) return '2021-2025';
  return '2026~';
}

// ── 공유 위젯 ──────────────────────────────────────────────────────────────────

class StatsBarRow extends StatelessWidget {
  final String label;
  final int count;
  final double ratio; // 0.0–1.0

  const StatsBarRow({
    super.key,
    required this.label,
    required this.count,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) => Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.dim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: constraints.maxWidth * ratio.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.cream, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsSectionCard extends StatelessWidget {
  final Widget child;
  const StatsSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dim, width: 0.5),
      ),
      child: child,
    );
  }
}

class StatsSectionTitle extends StatelessWidget {
  final String text;
  const StatsSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }
}

class StatsSmallCover extends StatelessWidget {
  final String? coverUrl;
  final String title;
  const StatsSmallCover(
      {super.key, required this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(width: 36, height: 50, child: _buildChild()),
    );
  }

  Widget _buildChild() {
    if (coverUrl == null) return _placeholder();
    if (coverUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: coverUrl!,
        fit: BoxFit.cover,
        placeholder: (c, u) => _placeholder(),
        errorWidget: (c, u, e) => _placeholder(),
      );
    }
    return Image.file(File(coverUrl!),
        fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholder());
  }

  Widget _placeholder() {
    final ch = title.isNotEmpty ? title[0] : '?';
    return Container(
      color: AppColors.surface3,
      alignment: Alignment.center,
      child: Text(ch,
          style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 14)),
    );
  }
}
