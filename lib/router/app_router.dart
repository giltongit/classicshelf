import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/csv_import_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/scan_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_author_screen.dart';
import '../screens/stats_monthly_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/stats_wishlist_screen.dart';
import '../screens/stats_year_screen.dart';
import '../screens/unified_search_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ── 하단 탭 4개 (홈 / 서가 / 통계 / 설정) ────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BookListScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
            routes: [
              GoRoute(
                path: 'year',
                builder: (context, state) => const StatsYearScreen(),
              ),
              GoRoute(
                path: 'author',
                builder: (context, state) => const StatsAuthorScreen(),
              ),
              GoRoute(
                path: 'monthly',
                builder: (context, state) => const StatsMonthlyScreen(),
              ),
              GoRoute(
                path: 'wishlist',
                builder: (context, state) => const StatsWishlistScreen(),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ]),
      ],
    ),

    // ── 탭 외부 라우트 (하단 탭 없음) ────────────────────────────────────────
    GoRoute(
      path: '/add',
      builder: (context, state) {
        final extra = state.extra;
        return AddBookScreen(
          editBook:      extra is Book ? extra : null,
          searchResult:  extra is BookSearchResult ? extra : null,
        );
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final p = state.uri.queryParameters;
        return UnifiedSearchScreen(
          initialTab:   p['tab'] == 'library' ? 1 : 0,
          initialIsbn:  p['isbn'],
          initialQuery: p['query'],
        );
      },
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/books/:id',
      builder: (context, state) => BookDetailScreen(
        localId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/csv-import',
      builder: (context, state) => const CsvImportScreen(),
    ),
  ],
);
