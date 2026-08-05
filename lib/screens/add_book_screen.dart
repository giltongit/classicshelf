// =============================================================================
// add_book_screen.dart — 음반 등록 폼 (2B-2a 뼈대)
//   파일명은 라우팅 참조를 줄이려고 유지, 클래스는 AddAlbumScreen.
//
// 범위: Step 1·2·4 + Step 3(수록곡 카드 N개 + 악장) + 저장 + 편집 모드.
//   2B-2a 뼈대 → 2B-2b-① 편집 모드 → 2B-2b-② 악장 입력.
//
// 설계 전제(확정):
//   · AlbumDraft 계층을 두지 않는다 — 화면 상태에서 바로 Album 애그리게이트를
//     조립해 saveAlbum에 넘긴다. (Draft는 대 2 자동입력에서 필요해지면)
//   · 모든 수록곡은 앨범 기본 연주자를 상속한다
//     (performerOverrides = null — 빈 리스트가 아니다. §3-2 상속 규칙).
//
// 신규/편집 한 화면 (albumId != null 이면 편집):
//   · id 보존이 결정적이다. 편집 모드는 pre-fill한 Album/Composition/Performer의
//     id를 전부 그대로 실어 saveAlbum에 넘긴다 — saveAlbum이
//     insertOnConflictUpdate + 하위 replace라 같은 id면 수정으로 처리된다.
//     id를 새로 뽑으면 같은 앨범이 하나 더 생긴다.
//   · 편집 중 새로 추가한 행/카드만 uuid.v4()를 받는다(생성자 분리).
//
// UI: 스텝퍼 대신 단일 스크롤 + 섹션 헤더 4개(뼈대 단계라 단순하게).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/album.dart';
import '../models/work.dart';
import '../providers/providers.dart';
import '../services/wish_resolution.dart';
import '../theme/app_theme.dart';
import '../widgets/form_fields.dart';
import '../widgets/wish_resolution_dialog.dart';

const _uuid = Uuid();

/// 포맷 선택지 — 필터 시트와 공유한다(album.dart의 kAlbumFormats).
const _formats = kAlbumFormats;

class AddAlbumScreen extends ConsumerStatefulWidget {
  /// null이면 신규 등록, 값이 있으면 그 앨범의 편집 모드.
  final String? albumId;

  const AddAlbumScreen({super.key, this.albumId});

  @override
  ConsumerState<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends ConsumerState<AddAlbumScreen> {
  // ── Step 1. 음반 기본정보 ──
  final _title = TextEditingController();
  final _label = TextEditingController();
  final _releaseYear = TextEditingController();
  final _discCount = TextEditingController(text: '1');
  String? _format;

  // ── Step 2. 기본 연주자 ──
  final List<_PerformerRow> _performers = [];

  // ── Step 3. 수록곡 ──
  // 신규는 빈 카드 하나로 시작한다(편집은 pre-fill이 채운다).
  final List<_CompositionCard> _compositions = [];

  // ── Step 4. 사용자 정보 ──
  DateTime? _acquiredAt;
  final _location = TextEditingController();
  final _review = TextEditingController();

  // 폼에 입력란이 없는 필드 — 편집 시 기존 값을 그대로 보존한다.
  // saveAlbum은 Album 통째로 덮어쓰므로(LWW), 여기서 들고 있지 않으면
  // 편집 저장 한 번에 커버·바코드·처분 상태가 null로 지워진다.
  // LWW 통째 덮어쓰기: 폼에 노출 안 된 필드도 pre-fill 값을 실어야 유실 안 됨.
  //   필드 추가 시 이 패턴 유지할 것.
  String? _coverUrl;
  String? _barcode;
  DateTime? _disposedAt;

  /// 저장에 쓸 앨범 id. 편집이면 기존 id, 신규면 진입 시 발급한 uuid.
  /// 진입 시 한 번만 정하는 이유: 저장 실패 후 재시도해도 같은 id여야
  /// 서버 upsert가 멱등하다(중복 앨범 방지).
  late final String _albumId;
  bool get _isEditing => widget.albumId != null;

  bool _saving = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _albumId = widget.albumId ?? _uuid.v4();
    if (_isEditing) {
      _loading = true;
      _loadForEdit(widget.albumId!);
    } else {
      _compositions.add(_CompositionCard());
    }
  }

  /// 편집 진입 — 로컬에서 애그리게이트를 읽어 폼을 채운다.
  /// 조회 경로는 getAlbum 하나뿐이라 상세 화면과 같은 값을 본다.
  Future<void> _loadForEdit(String id) async {
    Album? album;
    try {
      album = await ref.read(collectionRepositoryProvider).getAlbum(id);
    } catch (e) {
      debugPrint('[FORM] 편집 로드 실패 id=$id: $e');
    }
    if (!mounted) return;

    if (album == null) {
      // 로컬에 없는 앨범 — 안내 후 되돌아간다.
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('앨범을 찾을 수 없습니다')));
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _title.text = album!.title;
      _label.text = album.label ?? '';
      _releaseYear.text = album.releaseYear?.toString() ?? '';
      _discCount.text = album.discCount.toString();
      _format = album.format;
      _acquiredAt = album.acquiredAt;
      _location.text = album.location ?? '';
      _review.text = album.review ?? '';
      _coverUrl = album.coverUrl;
      _barcode = album.barcode;
      _disposedAt = album.disposedAt;

      // 기존 id를 그대로 물고 오는 생성자 — 저장 시 수정으로 처리되게 한다.
      _performers.addAll(album.defaultPerformers.map(_PerformerRow.existing));
      _compositions.addAll(
        ([...album.compositions]..sort((a, b) => a.seq.compareTo(b.seq)))
            .map(_CompositionCard.existing),
      );
      // 수록곡이 없던 앨범이면 빈 카드 하나를 띄워 입력을 유도한다.
      if (_compositions.isEmpty) _compositions.add(_CompositionCard());
      _loading = false;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _label.dispose();
    _releaseYear.dispose();
    _discCount.dispose();
    _location.dispose();
    _review.dispose();
    for (final p in _performers) {
      p.dispose();
    }
    for (final c in _compositions) {
      c.dispose();
    }
    super.dispose();
  }

  // ===========================================================================
  // 저장 — 화면 상태 → Album 애그리게이트 → saveAlbum
  // ===========================================================================

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final title = _title.text.trim();
    if (title.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('음반 제목을 입력해 주세요')));
      return;
    }

    // 수록곡 조립 — 작곡가가 빈 카드는 조용히 제외한다(오류로 막지 않는다).
    // 빈 카드 하나로 시작하는 UI라, 그걸 오류로 세우면 정상 흐름이 막힌다.
    // 대신 유효한 곡이 0개면 아래에서 한 번만 명확히 안내한다.
    final compositions = <Composition>[];
    var droppedPartial = 0; // 뭔가 입력했는데 작곡가가 없어 빠진 카드 수
    for (final card in _compositions) {
      if (card.composer.text.trim().isEmpty) {
        if (!card.isBlank) droppedPartial++;
        continue;
      }
      // 악장 조립 — 제목 없는 행은 조용히 제외(선택 입력이라 오류로 막지 않는다).
      // 편집 시 손대지 않은 악장도 pre-fill된 행 그대로 다시 실려 유실되지 않는다.
      final movements = <Movement>[];
      for (final mr in card.movements) {
        final mt = mr.title.text.trim();
        if (mt.isEmpty) continue;
        movements.add(Movement(
          id: mr.id, // 편집이면 기존 악장 id 유지
          seq: movements.length, // 행 순서 = seq (0, 1, 2…)
          title: mt,
          trackNo: int.tryParse(mr.trackNo.text.trim()),
          durationSec: _parseDurationSec(mr.duration.text),
        ));
      }

      // 곡별 연주자 예외 — 이름이 빈 행은 제외.
      // 유효한 행이 하나도 없으면 빈 리스트가 아니라 **null**을 넣는다:
      // getAlbum·syncFromRemote가 "행 없음 → null(=상속)"로 조립하므로,
      // 저장 쪽도 null로 맞춰야 왕복해도 형태가 흔들리지 않는다.
      final overrides = card.overrides
          .where((p) => p.name.text.trim().isNotEmpty)
          .map((p) => Performer(
                id: p.id, // 편집이면 기존 연주자 id 유지
                role: p.role,
                name: p.name.text.trim(),
              ))
          .toList();

      compositions.add(Composition(
        id: card.id,
        title: _nullIfEmpty(card.title.text),
        composer: card.composer.text.trim(),
        // 자동완성에서 고른 정규 작품. 안 골랐으면 null(미매칭 허용, §3-4).
        workId: card.workId,
        catalogNumber: _nullIfEmpty(card.catalogNumber.text),
        discNo: int.tryParse(card.discNo.text.trim()),
        trackFrom: int.tryParse(card.trackFrom.text.trim()),
        trackTo: int.tryParse(card.trackTo.text.trim()),
        seq: compositions.length, // 카드 순서 = seq (0, 1, 2…)
        // 사용자가 직접 입력한 값이므로 confirmed.
        // 자동입력(대 2)이 생기면 그 경로만 unverified로 들어온다.
        confidence: Confidence.confirmed,
        movements: movements,
        // null = 앨범 기본값 상속 (§3-2). 빈 리스트를 넣지 않는다.
        performerOverrides: overrides.isEmpty ? null : overrides,
      ));
    }

    // 이름이 빈 연주자 행은 버린다(역할만 고른 채 두고 저장하는 경우).
    final performers = _performers
        .where((p) => p.name.text.trim().isNotEmpty)
        .map((p) => Performer(
              id: p.id,
              role: p.role,
              name: p.name.text.trim(),
            ))
        .toList();

    // 음반은 곡이 있어야 의미가 있다 — 유효한 수록곡 0개는 저장하지 않는다.
    if (compositions.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('수록곡을 하나 이상 입력해 주세요')),
      );
      return;
    }

    final album = Album(
      id: _albumId, // 편집이면 기존 id — saveAlbum이 수정으로 처리한다
      title: title,
      label: _nullIfEmpty(_label.text),
      releaseYear: int.tryParse(_releaseYear.text.trim()),
      discCount: int.tryParse(_discCount.text.trim()) ?? 1,
      format: _format,
      // TODO: 2B-2b — 바코드 스캔(§4-3) · 커버 촬영·업로드
      //   입력란은 아직 없고, 편집 시 기존 값을 잃지 않게 그대로 싣는다.
      barcode: _barcode,
      coverUrl: _coverUrl,
      location: _nullIfEmpty(_location.text),
      review: _nullIfEmpty(_review.text),
      acquiredAt: _acquiredAt,
      // 신규는 언제나 소장중(null). 편집은 기존 처분 상태를 보존한다(§6-2).
      // TODO: 2B-2b — 처분·분실 전환 UI
      disposedAt: _disposedAt,
      defaultPerformers: performers,
      compositions: compositions,
    );

    setState(() => _saving = true);
    try {
      // 오프라인이어도 로컬 커밋 후 큐에 쌓이므로 여기서 온라인을 따지지 않는다.
      await ref.read(collectionRepositoryProvider).saveAlbum(album);
      if (!mounted) return;
      // 목록은 albumSummariesProvider(Drift watch)라 자동 갱신되지만,
      // 상세는 FutureProvider.family(진입 시 1회 조회)라 직접 무효화해야
      // 수정 결과가 보인다.
      if (_isEditing) ref.invalidate(albumDetailProvider(_albumId));

      // 위시 자동 해소 감지(§17-21). 폼을 닫기 전에 물어본다 — pop 후에는
      // 이 화면의 context가 사라져 다이얼로그를 띄울 자리가 없다.
      final resolved = await _checkWishResolution(album);
      if (!mounted) return;

      navigator.pop();
      final dropped =
          droppedPartial > 0 ? ' (작곡가 없는 수록곡 $droppedPartial개 제외)' : '';
      final wish = resolved > 0 ? ' · 희망 $resolved건 해소' : '';
      messenger.showSnackBar(SnackBar(
        content: Text('「$title」 ${_isEditing ? '수정' : '등록'}됨$dropped$wish'),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  /// 방금 저장한 앨범 하나만 활성 위시 전체와 대조한다(§17-21 트리거 ①).
  /// 저장은 이미 끝났으므로 여기서 실패해도 저장 결과를 되돌리지 않는다 —
  /// 감지는 부가 기능이라 조용히 넘긴다.
  Future<int> _checkWishResolution(Album album) async {
    // 처분한 앨범은 소장이 아니다 — 위시가 여전히 유효하다.
    if (album.disposedAt != null) return 0;
    try {
      final wishes = await ref.read(collectionRepositoryProvider).getWishlist();
      final matches = findResolvedWishes(wishes, compositionKeysOf(album));
      if (!mounted) return 0;
      return await promptWishResolution(context, ref, matches);
    } catch (e) {
      debugPrint('[WISH] 자동 해소 감지 실패(무시): $e');
      return 0;
    }
  }

  String? _nullIfEmpty(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _pickAcquiredAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquiredAt ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '취득일 선택',
    );
    if (picked != null) setState(() => _acquiredAt = picked);
  }

  // ===========================================================================
  // 빌드
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('음반 수정')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '음반 수정' : '음반 등록'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              '저장',
              style: TextStyle(
                color: _saving ? AppColors.muted : AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // ── Step 1 ──
            const _SectionLabel('음반 정보'),
            const SizedBox(height: 12),
            AppTextField(
              controller: _title,
              label: '제목 *',
              hint: '예: Goldberg Variations',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _label,
              label: '레이블',
              hint: '예: Deutsche Grammophon',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _releaseYear,
                    label: '발매연도',
                    hint: '예: 1981',
                    numeric: true,
                    maxLength: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _discCount,
                    label: '디스크 수',
                    numeric: true,
                    maxLength: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _MiniLabel('포맷'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _formats.map((f) {
                final selected = _format == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.bg : AppColors.cream,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.surface2,
                  selectedColor: AppColors.gold,
                  side: BorderSide(
                    color: selected ? AppColors.gold : AppColors.dim,
                  ),
                  // 다시 누르면 해제 — 포맷은 선택 항목이다.
                  onSelected: (v) => setState(() => _format = v ? f : null),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 20),

            // ── Step 2 ──
            const _SectionLabel('기본 연주자'),
            const SizedBox(height: 4),
            const Text(
              '수록곡이 물려받는 값입니다. 비워도 됩니다.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ..._performers.map((row) => _buildPerformerRow(
                  row,
                  onDelete: () => setState(() {
                    _performers.remove(row);
                    row.dispose();
                  }),
                )),
            const SizedBox(height: 4),
            _AddButton(
              label: '연주자 추가',
              onPressed: () => setState(
                () => _performers.add(_PerformerRow()),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 20),

            // ── Step 3 ──
            _SectionLabel('수록곡 ${_compositions.length}곡'),
            const SizedBox(height: 4),
            const Text(
              '작곡가와 작품번호로 충분합니다. 악장은 나중에 추가할 수 있습니다.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            // TODO: 2B-2b-③ — 6곡 이상이면 표 전환 (§4-3)
            // TODO: 2B-2b-③ — 세트(전집) 일괄 추가
            // TODO: 2B-2b-③ — 곡별 연주자 override(상속 예외)
            // TODO: Work 매칭·자동완성은 대 2
            ...List.generate(
              _compositions.length,
              (i) => _buildCompositionCard(i),
            ),
            const SizedBox(height: 4),
            _AddButton(
              label: '작품 추가',
              onPressed: () => setState(
                () => _compositions.add(_CompositionCard()),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 20),

            // ── Step 4 ──
            const _SectionLabel('소장 정보'),
            const SizedBox(height: 12),
            // TODO: 2B-2b(또는 1-D) — 희망 목록으로 등록하는 경로
            //   지금은 소장(Album 저장) 전용. Wishlist는 별도 애그리게이트라
            //   saveWishItem 경로를 따로 태워야 한다.
            _DateField(
              label: '취득일',
              value: _acquiredAt,
              onTap: _pickAcquiredAt,
              onClear: _acquiredAt == null
                  ? null
                  : () => setState(() => _acquiredAt = null),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _location,
              label: '보관 위치',
              hint: '예: 거실 선반 2단',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _review,
              label: '메모',
              hint: '감상·구입 경위 등',
              maxLines: 4,
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.bg,
                      ),
                    )
                  : const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  // ── 연주자 행 — 앨범 기본(Step 2)과 곡별 override가 공유한다.
  //   구조가 같아야 사용자가 "같은 것을 다른 층위에 적는다"고 읽는다.
  Widget _buildPerformerRow(
    _PerformerRow row, {
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 116,
            child: DropdownButtonFormField<PerformerRole>(
              initialValue: row.role,
              isDense: true,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              dropdownColor: AppColors.surface2,
              style: const TextStyle(color: AppColors.cream, fontSize: 13),
              items: PerformerRole.values
                  .where((r) => r != PerformerRole.unknown)
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(_roleLabel(r)),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => row.role = v ?? PerformerRole.conductor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppTextField(controller: row.name, hint: '이름'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            tooltip: '삭제',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  // ── Step 3 카드 ──
  Widget _buildCompositionCard(int index) {
    final card = _compositions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dim),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // 카드가 하나뿐이면 지우지 않고 비워 두면 된다(저장 시 무시).
              if (_compositions.length > 1)
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: AppColors.muted),
                  tooltip: '이 작품 삭제',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() {
                    _compositions.removeAt(index);
                    card.dispose();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AutocompleteField<String>(
            controller: card.composer,
            focusNode: card.composerFocus,
            label: '작곡가 *',
            hint: '예: J.S. Bach',
            search: (q) =>
                ref.read(collectionRepositoryProvider).suggestComposers(q),
            displayString: (s) => s,
            optionBuilder: (s) => Text(s,
                style: const TextStyle(
                    color: AppColors.cream, fontSize: 14)),
            onSelected: (_) => setState(() {
              // 작곡가가 바뀌면 이전 매칭은 더는 유효하지 않다.
              card.workId = null;
              card.matchedTitle = null;
            }),
            onChanged: (_) => setState(() {
              card.workId = null;
              card.matchedTitle = null;
            }),
          ),
          const SizedBox(height: 10),
          // 제목은 가장 길어 한 줄을 통째로 쓴다. 자동완성에서 고르면 정규 작품과
          // 이어지고(workId), 자유 입력이면 표지에서 읽은 그대로만 남는다.
          AutocompleteField<Work>(
            controller: card.title,
            focusNode: card.titleFocus,
            label: '작품 제목',
            hint: '예: Goldberg Variations',
            search: (q) => ref
                .read(collectionRepositoryProvider)
                .suggestWorks(card.composer.text, q),
            displayString: (w) => w.title,
            optionBuilder: (w) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title,
                    style: const TextStyle(
                        color: AppColors.cream, fontSize: 14)),
                if (w.genre != null || w.period != null)
                  Text(
                    [w.genre, w.period].whereType<String>().join(' · '),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                  ),
              ],
            ),
            onSelected: (w) => setState(() {
              card.workId = w.id;
              card.matchedTitle = w.title;
            }),
            onChanged: (v) => setState(() {
              // 고른 뒤 제목을 손으로 고치면 참조와 표기가 어긋난다 — 매칭 해제.
              if (card.matchedTitle != null && v != card.matchedTitle) {
                card.workId = null;
                card.matchedTitle = null;
              }
            }),
          ),
          if (card.workId != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '작품 데이터와 연결됨',
                    style: TextStyle(
                        color: AppColors.gold.withValues(alpha: 0.9),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          AppTextField(
            controller: card.catalogNumber,
            label: '작품번호',
            hint: '예: BWV 988',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: card.discNo,
                  label: '디스크',
                  numeric: true,
                  maxLength: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: card.trackFrom,
                  label: '시작 트랙',
                  numeric: true,
                  maxLength: 3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: card.trackTo,
                  label: '끝 트랙',
                  numeric: true,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMovementsSection(card),
          const SizedBox(height: 8),
          _buildOverridesSection(card),
        ],
      ),
    );
  }

  // ── Step 3 카드 안 · 곡별 연주자 override 섹션 ──
  //   비어 있으면 곧 "상속"이다(§3-2). 열었다가 비우고 닫아도 상속으로 돌아간다.
  Widget _buildOverridesSection(_CompositionCard card) {
    final n = card.overrides.length;

    if (!card.overridesExpanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() {
            card.overridesExpanded = true;
            if (card.overrides.isEmpty) card.overrides.add(_PerformerRow());
          }),
          icon: Icon(n == 0 ? Icons.person_add_alt : Icons.expand_more,
              size: 16),
          label: Text(
            n == 0 ? '이 곡 연주자 지정' : '이 곡 연주자 $n명',
            style: const TextStyle(fontSize: 13),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    // 앨범 기본값 요약 — 무엇을 덮어쓰는 중인지 보이게 한다.
    final defaults = _performers
        .where((p) => p.name.text.trim().isNotEmpty)
        .map((p) => '${_roleLabel(p.role)} ${p.name.text.trim()}')
        .join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => card.overridesExpanded = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text(
                    '이 곡만의 연주자',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_less,
                      size: 16, color: AppColors.muted),
                  const Spacer(),
                  const Text(
                    '선택 입력',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // 상속 규칙 안내 — 역할 단위 병합이라는 점을 사용자가 알아야
          // "관현악은 왜 안 적었는데 남아 있지?"에서 놀라지 않는다.
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '지정한 역할만 앨범 기본값을 덮어씁니다. 비워 두면 전부 상속합니다.',
              style: TextStyle(
                  color: AppColors.muted, fontSize: 11, height: 1.4),
            ),
          ),
          if (defaults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '앨범 기본: $defaults',
                style: const TextStyle(
                    color: AppColors.dim, fontSize: 11, height: 1.4),
              ),
            ),
          ...card.overrides.map((row) => _buildPerformerRow(
                row,
                onDelete: () => setState(() {
                  card.overrides.remove(row);
                  row.dispose();
                  // 마지막 행을 지우면 접어서 "상속" 상태로 되돌린다.
                  if (card.overrides.isEmpty) card.overridesExpanded = false;
                }),
              )),
          TextButton.icon(
            onPressed: () =>
                setState(() => card.overrides.add(_PerformerRow())),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('연주자 추가', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3 카드 안 · 악장 섹션 ──
  //   기본 접힘. 다악장 곡이 아닌 경우가 많아, 펼쳐두면 카드만 길어진다.
  Widget _buildMovementsSection(_CompositionCard card) {
    final n = card.movements.length;

    // 접힘 — 악장이 없으면 추가 버튼만, 있으면 개수 요약.
    if (!card.movementsExpanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() {
            card.movementsExpanded = true;
            if (card.movements.isEmpty) card.movements.add(_MovementRow());
          }),
          icon: Icon(n == 0 ? Icons.add : Icons.expand_more, size: 16),
          label: Text(
            n == 0 ? '악장 추가' : '악장 $n개',
            style: const TextStyle(fontSize: 13),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    // 펼침 — 헤더(접기) + 악장 행들 + 추가 버튼.
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => card.movementsExpanded = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    n == 0 ? '악장' : '악장 $n개',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_less,
                      size: 16, color: AppColors.muted),
                  const Spacer(),
                  const Text(
                    '선택 입력',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(
            card.movements.length,
            (i) => _buildMovementRow(card, i),
          ),
          TextButton.icon(
            onPressed: () =>
                setState(() => card.movements.add(_MovementRow())),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('악장 추가', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementRow(_CompositionCard card, int index) {
    final row = card.movements[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              Expanded(
                child: AppTextField(
                  controller: row.title,
                  hint: '악장 제목 (예: II. Andante)',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
                tooltip: '이 악장 삭제',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => setState(() {
                  card.movements.removeAt(index);
                  row.dispose();
                  // 마지막 악장을 지우면 섹션을 접어 카드를 정리한다.
                  if (card.movements.isEmpty) card.movementsExpanded = false;
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 32, top: 6),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: row.trackNo,
                    label: '트랙',
                    numeric: true,
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    controller: row.duration,
                    label: '길이',
                    hint: '4:32',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _roleLabel(PerformerRole r) => switch (r) {
      PerformerRole.conductor => '지휘',
      PerformerRole.orchestra => '악단',
      PerformerRole.soloist => '독주',
      PerformerRole.ensemble => '앙상블',
      PerformerRole.vocalist => '성악',
      PerformerRole.unknown => '기타',
    };

// ─────────────────────────────────────────────────────────────────────────────
// 화면 상태 홀더 — 행/카드 생성 시점에 uuid를 확정한다.
//   저장 때 새로 발급하지 않는 이유: 저장 실패 후 재시도해도 같은 id를 유지해야
//   서버에 중복 행이 생기지 않는다(멱등 upsert).
// ─────────────────────────────────────────────────────────────────────────────

class _PerformerRow {
  final String id;
  PerformerRole role;
  final TextEditingController name = TextEditingController();

  /// 새로 추가한 행 — 여기서 id가 확정된다.
  _PerformerRow()
      : id = _uuid.v4(),
        role = PerformerRole.conductor;

  /// 편집 pre-fill — 기존 행의 id를 물고 온다.
  _PerformerRow.existing(Performer p)
      : id = p.id,
        role = p.role {
    name.text = p.name;
  }

  void dispose() => name.dispose();
}

class _MovementRow {
  final String id;
  final TextEditingController title = TextEditingController();
  final TextEditingController trackNo = TextEditingController();

  /// mm:ss 로 입력받아 저장 시 초로 바꾼다(모델은 durationSec).
  final TextEditingController duration = TextEditingController();

  /// 새로 추가한 악장 — 여기서 id가 확정된다.
  _MovementRow() : id = _uuid.v4();

  /// 편집 pre-fill — 기존 악장의 id를 물고 온다.
  _MovementRow.existing(Movement m) : id = m.id {
    title.text = m.title;
    trackNo.text = m.trackNo?.toString() ?? '';
    duration.text = _durationToText(m.durationSec);
  }

  void dispose() {
    title.dispose();
    trackNo.dispose();
    duration.dispose();
  }
}

class _CompositionCard {
  final String id;
  final TextEditingController composer = TextEditingController();
  final TextEditingController title = TextEditingController();
  final TextEditingController catalogNumber = TextEditingController();
  final TextEditingController discNo = TextEditingController();
  final TextEditingController trackFrom = TextEditingController();
  final TextEditingController trackTo = TextEditingController();

  /// 악장 — 선택 입력. 단악장 곡(서곡·교향시·소품)이 많아 강제하지 않는다.
  final List<_MovementRow> movements = [];

  /// 곡별 연주자 예외(§3-2). 비어 있으면 앨범 기본값을 그대로 상속한다.
  /// 상속은 role 단위 병합이라, 여기 담은 역할만 덮이고 나머지는 상속된다.
  final List<_PerformerRow> overrides = [];

  /// 섹션 펼침 여부(카드별). 기본 접힘 — 카드가 길어지는 걸 막는다.
  bool movementsExpanded = false;
  bool overridesExpanded = false;

  /// 정규 작품 참조(§3-4). 자동완성에서 작품을 고르면 채워지고, 자유 입력이면
  /// null로 남는다 — 매칭은 어디까지나 선택이라 기존 자유 텍스트 흐름을 막지 않는다.
  String? workId;

  /// workId를 채울 때 고른 작품의 제목. 이후 제목을 손으로 고치면 매칭이 더는
  /// 유효하지 않으므로 workId를 떨군다(제목과 참조가 어긋나는 걸 막는다).
  String? matchedTitle;

  /// 자동완성(RawAutocomplete)이 요구하는 포커스 노드. 카드마다 하나씩.
  final composerFocus = FocusNode();
  final titleFocus = FocusNode();

  /// 새로 추가한 카드 — 여기서 id가 확정된다.
  _CompositionCard() : id = _uuid.v4();

  /// 편집 pre-fill — 기존 수록곡의 id를 물고 온다.
  /// 이 id가 유지되어야 저장 시 같은 행을 수정하고, 카드를 지우면
  /// 하위(악장·곡별 연주자)까지 고아 없이 함께 삭제된다.
  /// 악장도 같은 규칙 — 기존 id를 그대로 물고 와야 수정으로 처리된다.
  _CompositionCard.existing(Composition c) : id = c.id {
    composer.text = c.composer;
    title.text = c.title ?? '';
    // 정규 작품 참조를 물고 온다. 폼에 입력란이 따로 없는 값이라 여기서 안 실으면
    // 편집 저장 때 통째 덮어쓰기(§3-2)로 매칭이 조용히 날아간다.
    workId = c.workId;
    matchedTitle = c.workId == null ? null : c.title;
    catalogNumber.text = c.catalogNumber ?? '';
    discNo.text = c.discNo?.toString() ?? '';
    trackFrom.text = c.trackFrom?.toString() ?? '';
    trackTo.text = c.trackTo?.toString() ?? '';
    // 폼에서 악장을 건드리지 않아도 저장 시 그대로 다시 실린다(유실 방지).
    movements.addAll(
      ([...c.movements]..sort((a, b) => a.seq.compareTo(b.seq)))
          .map(_MovementRow.existing),
    );
    // null(=상속)이면 비워 둔다 — 빈 섹션이 곧 상속을 뜻한다.
    overrides.addAll(
      (c.performerOverrides ?? const <Performer>[]).map(_PerformerRow.existing),
    );
  }

  /// 아무것도 입력하지 않은 카드 — 저장 시 조용히 버린다.
  bool get isBlank =>
      composer.text.trim().isEmpty &&
      title.text.trim().isEmpty &&
      catalogNumber.text.trim().isEmpty &&
      discNo.text.trim().isEmpty &&
      trackFrom.text.trim().isEmpty &&
      trackTo.text.trim().isEmpty &&
      movements.isEmpty &&
      overrides.isEmpty;

  void dispose() {
    composerFocus.dispose();
    titleFocus.dispose();
    composer.dispose();
    title.dispose();
    catalogNumber.dispose();
    discNo.dispose();
    trackFrom.dispose();
    trackTo.dispose();
    for (final m in movements) {
      m.dispose();
    }
    for (final p in overrides) {
      p.dispose();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 재생시간 변환 — 모델은 초(durationSec), 입력은 mm:ss.
// ─────────────────────────────────────────────────────────────────────────────

/// "m:ss" → 초. 콜론이 없으면 초 단위 숫자로 본다. 형식이 어긋나면 null(= 미입력).
/// 저장을 막지 않는다 — 선택 입력이라 잘못 적었다고 흐름을 세우지 않는다.
int? _parseDurationSec(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  if (!t.contains(':')) return int.tryParse(t);
  final parts = t.split(':');
  if (parts.length != 2) return null;
  final m = int.tryParse(parts[0].trim());
  final sec = int.tryParse(parts[1].trim());
  if (m == null || sec == null) return null;
  return m * 60 + sec;
}

/// 초 → "m:ss" (편집 pre-fill 표시용). 상세 화면 표기와 같은 형식.
String _durationToText(int? sec) {
  if (sec == null) return '';
  return '${sec ~/ 60}:${(sec % 60).toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// 공용 위젯
//   AppTextField / AutocompleteField는 위시 편집 시트(§17-20)와 공유하려고
//   widgets/form_fields.dart로 옮겼다.
// ─────────────────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '선택 안 함'
        : '${value!.year}. ${value!.month}. ${value!.day}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: value == null ? AppColors.muted : AppColors.cream,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 16, color: AppColors.muted),
              )
            else
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
    );
  }
}
