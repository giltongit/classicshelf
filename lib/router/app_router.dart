import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/scan_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BookListScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) {
        final extra = state.extra;
        return AddBookScreen(
          editBook:     extra is Book             ? extra : null,
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
  ],
);
