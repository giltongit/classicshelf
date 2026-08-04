// =============================================================================
// album_filter_sheet.dart — 서가 필터 시트 (대 1-E)
//   §6-3의 필터 축을 화면에 연결한다. 리포지토리 쿼리(getAlbumSummaries)는
//   이미 전 축을 처리하므로 여기서 거르거나 정렬하지 않는다 — 값만 만들어 준다.
//
// 임시 편집 후 "적용"에서 커밋한다(매 토글마다 provider를 갱신하지 않는다).
//   조합 필터는 중간 상태가 의미 없는 경우가 많아(작곡가만 고른 순간의 목록),
//   화면이 깜빡이며 재조회되는 것보다 한 번에 반영하는 편이 덜 어수선하다.
//   취소(시트 닫기)하면 아무것도 반영되지 않는다.
//
// composer·conductor는 **정확 일치** 매칭이라(§6-3 쿼리) 자유 텍스트로 받지
//   않는다. 등록된 값에서 뽑은 목록(filterFacetsProvider)에서 고르게 한다.
//
// period(시대) 축은 이번 시트에 없다: 쿼리가 works.period를 조인하는데 Works
//   시드(대 1-A)가 미착수라 테이블이 비어 어떤 값이든 0건이 된다. 모델 필드와
//   리포지토리 쿼리는 그대로 두었으므로 시드 후 칩만 붙이면 된다(§17).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/album.dart' show HoldingStatus, kAlbumFormats;
import '../models/album_filter.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// 서가 필터 시트를 연다. 적용 시 albumFilterProvider가 갱신되고,
/// 목록은 reactive(watch)라 따로 새로고침할 필요가 없다.
void showAlbumFilterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true, // 선택지가 많으면 시트가 길어진다
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _AlbumFilterSheet(),
  );
}

class _AlbumFilterSheet extends ConsumerStatefulWidget {
  const _AlbumFilterSheet();

  @override
  ConsumerState<_AlbumFilterSheet> createState() => _AlbumFilterSheetState();
}

class _AlbumFilterSheetState extends ConsumerState<_AlbumFilterSheet> {
  /// 시트 안에서만 쓰는 임시 필터. "적용" 전까지 provider를 건드리지 않는다.
  late AlbumFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(albumFilterProvider);
  }

  void _apply() {
    ref.read(albumFilterProvider.notifier).update(_draft);
    Navigator.pop(context);
  }

  void _reset() => setState(() => _draft = _draft.clearedForSheet());

  @override
  Widget build(BuildContext context) {
    final facets = ref.watch(filterFacetsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '필터',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_draft.activeCount > 0)
                    Text(
                      '${_draft.activeCount}개 적용 중',
                      style: const TextStyle(
                          color: AppColors.gold, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 소장 상태 ──────────────────────────────────────────────
              const _SectionLabel('소장 상태'),
              Wrap(
                spacing: 8,
                children: [
                  _choice(
                    label: '전체',
                    selected: _draft.status == null,
                    onTap: () => setState(
                        () => _draft = _draft.copyWith(clearStatus: true)),
                  ),
                  _choice(
                    label: '소장 중',
                    selected: _draft.status == HoldingStatus.owned,
                    onTap: () => setState(() => _draft =
                        _draft.copyWith(status: HoldingStatus.owned)),
                  ),
                  _choice(
                    label: '처분',
                    selected: _draft.status == HoldingStatus.disposed,
                    onTap: () => setState(() => _draft =
                        _draft.copyWith(status: HoldingStatus.disposed)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 포맷 ──────────────────────────────────────────────────
              const _SectionLabel('포맷'),
              Wrap(
                spacing: 8,
                children: kAlbumFormats.map((f) {
                  final selected = _draft.format == f;
                  return _choice(
                    label: f,
                    selected: selected,
                    // 선택된 칩을 다시 누르면 해제(=전체).
                    onTap: () => setState(() => _draft = selected
                        ? _draft.copyWith(clearFormat: true)
                        : _draft.copyWith(format: f)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── 작곡가 · 지휘자 ────────────────────────────────────────
              _FacetDropdown(
                label: '작곡가',
                emptyHint: '등록된 작곡가가 없습니다',
                value: _draft.composer,
                options: facets.value?.composers,
                loading: facets.isLoading,
                onChanged: (v) => setState(() => _draft = v == null
                    ? _draft.copyWith(clearComposer: true)
                    : _draft.copyWith(composer: v)),
              ),
              const SizedBox(height: 16),
              _FacetDropdown(
                label: '지휘자',
                emptyHint: '등록된 지휘자가 없습니다',
                value: _draft.conductor,
                options: facets.value?.conductors,
                loading: facets.isLoading,
                onChanged: (v) => setState(() => _draft = v == null
                    ? _draft.copyWith(clearConductor: true)
                    : _draft.copyWith(conductor: v)),
              ),

              if (facets.hasError) ...[
                const SizedBox(height: 8),
                Text(
                  '선택지를 불러오지 못했습니다: ${facets.error}',
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),

              // ── 확인 필요만 ───────────────────────────────────────────
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeThumbColor: AppColors.gold,
                title: const Text(
                  '확인 필요만 보기',
                  style: TextStyle(color: AppColors.cream, fontSize: 14),
                ),
                subtitle: const Text(
                  '미확인 수록곡이 있는 음반',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                value: _draft.onlyNeedsVerification,
                onChanged: (v) => setState(
                    () => _draft = _draft.copyWith(onlyNeedsVerification: v)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  TextButton(
                    onPressed: _draft.activeCount == 0 ? null : _reset,
                    child: const Text('초기화',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                    ),
                    onPressed: _apply,
                    child: const Text('적용'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surface2,
        selectedColor: AppColors.goldSubtle,
        side: BorderSide(
          color: selected ? AppColors.gold : AppColors.dim,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.gold : AppColors.cream,
          fontSize: 13,
        ),
        showCheckmark: false,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      );
}

/// 등록된 값에서 고르는 드롭다운. 값이 없으면 비활성 + 안내.
class _FacetDropdown extends StatelessWidget {
  final String label;
  final String emptyHint;
  final String? value;
  final List<String>? options;
  final bool loading;
  final ValueChanged<String?> onChanged;

  const _FacetDropdown({
    required this.label,
    required this.emptyHint,
    required this.value,
    required this.options,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final opts = options ?? const <String>[];
    // 현재 선택값이 목록에 없을 수 있다(그 앨범을 지웠거나 값을 고친 경우).
    // 그대로 두면 DropdownButton이 중복/누락으로 단언 실패하므로 합쳐서 넣는다.
    final items = <String>{?value, ...opts}.toList()..sort();
    final enabled = !loading && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: value != null ? AppColors.gold : AppColors.dim),
          ),
          // FormField 계열(DropdownButtonFormField)은 initialValue가 외부에서
          // 바뀌어도 내부 상태를 따라가지 않아 "초기화" 후에도 옛 값이 남는다.
          // 완전 제어형 DropdownButton을 쓴다.
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              isDense: true,
              dropdownColor: AppColors.surface2,
              style: const TextStyle(color: AppColors.cream, fontSize: 14),
              icon: Icon(Icons.arrow_drop_down,
                  color: enabled ? AppColors.muted : AppColors.dim),
              hint: Text(
                loading ? '불러오는 중…' : (items.isEmpty ? emptyHint : '전체'),
                style: const TextStyle(color: AppColors.dim, fontSize: 14),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('전체', style: TextStyle(color: AppColors.muted)),
                ),
                ...items.map((o) => DropdownMenuItem<String?>(
                      value: o,
                      child: Text(o, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}
