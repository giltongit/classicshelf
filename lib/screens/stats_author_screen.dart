import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsAuthorScreen extends ConsumerWidget {
  const StatsAuthorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('저자 집중도')),
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
            final a = b.author.trim();
            if (a.isNotEmpty) counts[a] = (counts[a] ?? 0) + 1;
          }
          final maxVal =
              counts.values.isNotEmpty ? counts.values.reduce(max) : 0;
          if (maxVal <= 1) {
            return const Center(
              child: Text('다양한 저자의 책을 소장하고 있습니다',
                  style: TextStyle(color: AppColors.muted)),
            );
          }
          final sorted = counts.entries.toList()
            ..sort((a, b) => b.value != a.value
                ? b.value.compareTo(a.value)
                : a.key.compareTo(b.key));
          final top10 = sorted.take(10).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              StatsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatsSectionTitle('권수 기준 상위 10인 · 동점 가나다순'),
                    const SizedBox(height: 12),
                    ...top10.map((e) => StatsBarRow(
                          label: e.key,
                          count: e.value,
                          ratio: e.value / maxVal,
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
