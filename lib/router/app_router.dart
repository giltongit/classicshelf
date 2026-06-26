import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/csv_import_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/scan_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── 하단 탭 3개 (서재 / 통계 / 설정) ────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
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
          editBook: extra is Book ? extra : null,
          searchResult: extra is BookSearchResult ? extra : null,
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
