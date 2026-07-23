import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsWishlistScreen extends ConsumerWidget {
  const StatsWishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('오래 기다린 책')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) {
          final wishlist = books
              .where((b) => b.status == 'wishlist' && !b.isDisposed)
              .toList();
          if (wishlist.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 48, color: AppColors.dim),
                  SizedBox(height: 12),
                  Text('희망도서가 없습니다',
                      style: TextStyle(color: AppColors.muted, fontSize: 15)),
                ],
              ),
            );
          }
          final now = DateTime.now();
          final sorted = [...wishlist]
            ..sort((a, b) {
              final aDays = now.difference(a.createdAt ?? now).inDays;
              final bDays = now.difference(b.createdAt ?? now).inDays;
              return bDays.compareTo(aDays);
            });
          final top = sorted.take(20).toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: top.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.dim, height: 1),
            itemBuilder: (ctx, i) {
              final b = top[i];
              final days = now.difference(b.createdAt ?? now).inDays;
              return InkWell(
                onTap: () => context.push('/books/${b.localId}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      StatsSmallCover(
                          coverUrl: b.coverUrl, title: b.title),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(b.author,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12)),
                            const SizedBox(height: 3),
                            Text(
                              '$days일째 기다리는 중',
                              style: const TextStyle(
                                  color: AppColors.gold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.muted, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
