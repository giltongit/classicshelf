import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// =============================================================================
// add_book_screen.dart — 등록 화면 (2B-1 스텁)
//
// book 시절의 1,161줄짜리 등록 폼을 통째로 걷어냈다. 제거한 것:
//   - 신규/수정 분기(editBook), 검색 결과 프리필(searchResult), initialStatus
//   - bookRepositoryProvider.addBook / updateBook, booksProvider 무효화
//   - myTagsByKdcMain("내 분류" 태그), LibrarySearchService.getClassNo(KDC 자동조회)
//   - BookRepository 를 인자로 받던 저장 헬퍼, KDC 구조화 입력(대/중분류 드롭다운)
//   - 커버 촬영/업로드(CoverPhotoService, coverUploadProvider) — 2B-2에서 재사용
//
// TODO: 클래식 등록 폼 (2B-2) — §4-3 Step 1~4
//   Step 1. 음반 기본정보 — 제목 · 레이블 · 발매연도 · 포맷 · 커버.
//   Step 2. 작품 반복 블록 — 수록곡(Composition)마다 작품(Work) 선택/신규 +
//           악장(Movement) 목록. 앨범 하나에 작품이 여럿 붙으므로 블록 단위
//           추가/삭제/순서(seq) 조작이 필요하다.
//   Step 3. 연주자 상속 — 앨범 기본 연주자(albumPerformers)를 각 수록곡이
//           기본값으로 물려받고, 곡별로 덮어쓸 수 있어야 한다.
//   Step 4. 검토·저장 — CollectionRepository 의 단일 트랜잭션으로 저장.
//           확인 못 한 필드는 needsVerification 배지(§6-1)로 남긴다.
// =============================================================================

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음반 등록')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.album_outlined,
                  color: AppColors.gold, size: 48),
              const SizedBox(height: 16),
              const Text(
                '등록 기능 준비 중',
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '2B-2에서 구현합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                ),
                child: const Text('뒤로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
