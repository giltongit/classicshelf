import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsYearScreen extends ConsumerWidget {
  const StatsYearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('출판연도 분포')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) {
          final counts = <String, int>{};
          for (final b in books) {
            final k = yearBucket(b.year);
            counts[k] = (counts[k] ?? 0) + 1;
          }
          final rows = yearBucketOrder
              .where((k) => (counts[k] ?? 0) > 0)
              .map((k) => (k, counts[k]!))
              .toList();
          if (rows.isEmpty) {
            return const Center(
              child: Text('연도 정보가 없습니다',
                  style: TextStyle(color: AppColors.muted)),
            );
          }
          final maxVal = rows.map((r) => r.$2).reduce(max);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              StatsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatsSectionTitle('5년 단위 버킷 · 0권 버킷 생략'),
                    const SizedBox(height: 12),
                    ...rows.map((r) => StatsBarRow(
                          label: r.$1,
                          count: r.$2,
                          ratio: r.$2 / maxVal,
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
