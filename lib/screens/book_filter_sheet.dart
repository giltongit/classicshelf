import 'package:flutter/material.dart';

import '../models/book_filter.dart';
import '../theme/app_theme.dart';

class BookFilterSheet extends StatefulWidget {
  final BookFilter current;
  final List<String> allLocations;
  final ValueChanged<BookFilter> onApply;

  const BookFilterSheet({
    super.key,
    required this.current,
    required this.allLocations,
    required this.onApply,
  });

  @override
  State<BookFilterSheet> createState() => _BookFilterSheetState();
}

class _BookFilterSheetState extends State<BookFilterSheet> {
  late BookFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                children: [
                  const Text(
                    '필터 및 정렬',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        setState(() => _draft = const BookFilter()),
                    child: const Text('초기화',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dim, height: 1),
            // 내용
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _SectionTitle('정렬'),
                  _SortChips(
                    selected: _draft.sortBy,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(sortBy: v)),
                  ),
                  _SectionTitle('상태'),
                  _MultiChips(
                    items: const [
                      _ChipItem('소장', 'owned'),
                      _ChipItem('희망', 'wishlist'),
                      _ChipItem('대여', 'rental'),
                    ],
                    selected: _draft.statuses,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(statuses: v)),
                  ),
                  _SectionTitle('속성'),
                  _MultiChips(
                    items: const [
                      _ChipItem('우선읽기', 'priority'),
                      _ChipItem('읽음', 'read'),
                      _ChipItem('미읽음', 'unread'),
                    ],
                    selected: _draft.attributes,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(attributes: v)),
                  ),
                  _SectionTitle('매체'),
                  _MultiChips(
                    items: const [
                      _ChipItem('종이책', 'paper'),
                      _ChipItem('전자책', 'ebook'),
                      _ChipItem('오디오북', 'audio'),
                    ],
                    selected: _draft.media,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(media: v)),
                  ),
                  _SectionTitle('첫 글자'),
                  _InitialChips(
                    selected: _draft.initial,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(initial: v)),
                  ),
                  if (widget.allLocations.isNotEmpty) ...[
                    _SectionTitle('서가 위치'),
                    _MultiChips(
                      items: widget.allLocations
                          .map((l) => _ChipItem(l, l))
                          .toList(),
                      selected: _draft.locations,
                      onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(locations: v)),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // 적용 버튼
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.onApply(_draft);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '적용',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── 내부 모델 ───────────────────────────────────────────────────────────────────

class _ChipItem {
  final String label;
  final String value;
  const _ChipItem(this.label, this.value);
}

// ── 섹션 타이틀 ─────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── 단일 선택 정렬 칩 ───────────────────────────────────────────────────────────

class _SortChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _SortChips({required this.selected, required this.onChanged});

  static const _options = [
    _ChipItem('최신순', 'createdAt'),
    _ChipItem('제목', 'title'),
    _ChipItem('저자', 'author'),
    _ChipItem('연도', 'year'),
    _ChipItem('위치', 'location'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _options.map((opt) {
        final on = selected == opt.value;
        return GestureDetector(
          onTap: () => onChanged(opt.value),
          child: _chip(opt.label, on, solid: true),
        );
      }).toList(),
    );
  }
}

// ── 다중 선택 칩 ────────────────────────────────────────────────────────────────

class _MultiChips extends StatelessWidget {
  final List<_ChipItem> items;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _MultiChips({
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((item) {
        final on = selected.contains(item.value);
        return GestureDetector(
          onTap: () {
            final next = Set<String>.from(selected);
            on ? next.remove(item.value) : next.add(item.value);
            onChanged(next);
          },
          child: _chip(item.label, on),
        );
      }).toList(),
    );
  }
}

// ── 초성 칩 (단일 선택, 탭 다시 하면 해제) ──────────────────────────────────────

class _InitialChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _InitialChips({required this.selected, required this.onChanged});

  static const _all = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '#',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _all.map((ch) {
        final on = selected == ch;
        return GestureDetector(
          onTap: () => onChanged(on ? null : ch),
          child: Container(
            width: 36,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: on ? AppColors.gold : AppColors.dim),
            ),
            child: Text(
              ch,
              style: TextStyle(
                color: on ? AppColors.gold : AppColors.muted,
                fontSize: 12,
                fontWeight: on ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 공용 칩 빌더 ────────────────────────────────────────────────────────────────

Widget _chip(String label, bool on, {bool solid = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: on
          ? (solid ? AppColors.gold : AppColors.gold.withValues(alpha: 0.15))
          : AppColors.surface2,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: on ? AppColors.gold : AppColors.dim),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: on ? (solid ? AppColors.bg : AppColors.gold) : AppColors.muted,
        fontSize: 13,
        fontWeight: on ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}
