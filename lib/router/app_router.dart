import 'package:go_router/go_router.dart';

import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/settings_screen.dart';

// TODO: 클래식 재작성 (2B)
//   2A에서 제거한 라우트: /stats(+year/author/monthly/wishlist/genre),
//   /search, /book-search, /scan, /csv-import.
//   해당 화면 파일은 모두 삭제됨. 클래식 탭·라우트 구성은 2B에서 확정한다.

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ── 하단 탭 3개 (홈 / 서가 / 설정) ──────────────────────────────────────
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
            builder: (context, state) => const AlbumListScreen(),
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
    // TODO: 2B-2b — 편집 모드
    //   지금은 신규 등록 전용이라 extra(수정 대상 앨범·검색 결과 프리필)를 받지 않는다.
    //   편집을 붙일 때 앨범 id를 넘기는 분기를 되살릴 것.
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddAlbumScreen(),
    ),
    // 앨범 id는 클라이언트 생성 UUID(String)다. book 시절의 int localId 파싱을
    // 그대로 두면 UUID에서 예외가 나므로 경로도 /albums/:id 로 옮겼다.
    GoRoute(
      path: '/albums/:id',
      builder: (context, state) => AlbumDetailScreen(
        albumId: state.pathParameters['id']!,
      ),
    ),
  ],
);
