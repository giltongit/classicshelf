import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsMonthlyScreen extends ConsumerWidget {
  const StatsMonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final trackingAsync = ref.watch(trackingStartedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('월별 책과의 만남')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) => trackingAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold)),
          error: (e, _) => Center(
            child: Text('불러오기 실패: $e',
                style: const TextStyle(color: AppColors.red)),
          ),
          data: (trackingDate) {
            if (trackingDate == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '지금부터 나의 도서관에 새로 들어오는 책의 흐름을 기록합니다',
                      style: TextStyle(
                          color: AppColors.cream, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(trackingStartedProvider.notifier).startToday(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('오늘부터 시작'),
                    ),
                  ],
                ),
              );
            }

            // 최근 12개월 버킷 초기화
            final now = DateTime.now();
            final months = <String, int>{};
            for (var i = 11; i >= 0; i--) {
              final m = DateTime(now.year, now.month - i);
              months['${m.year}-${m.month.toString().padLeft(2, '0')}'] = 0;
            }

            // trackingStartedAt 이후 책만 집계 (effectiveDate = acquiredAt ∥ createdAt)
            for (final b in books) {
              final d = b.acquiredAt ?? b.createdAt;
              if (d == null) continue;
              if (d.isBefore(trackingDate)) continue;
              final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
              if (months.containsKey(key)) months[key] = months[key]! + 1;
            }

            final entries = months.entries.toList();
            final maxVal = entries.map((e) => e.value).reduce(max);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                StatsSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatsSectionTitle(
                          '${trackingDate.year}년 ${trackingDate.month}월부터 기록 중'),
                      const SizedBox(height: 12),
                      if (maxVal == 0)
                        const Text(
                          '아직 기록된 책이 없습니다',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13),
                        )
                      else
                        ...entries.map((e) {
                          final parts = e.key.split('-');
                          final label =
                              '${parts[0].substring(2)}년 ${int.parse(parts[1])}월';
                          return StatsBarRow(
                            label: label,
                            count: e.value,
                            ratio: e.value / maxVal,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
