// =============================================================================
// add_book_screen.dart — 음반 등록 폼 (2B-2a 뼈대)
//   파일명은 라우팅 참조를 줄이려고 유지, 클래스는 AddAlbumScreen.
//
// 범위(2B-2a): Step 1·2·4 + 최소 Step 3(수록곡 카드 N개) + 저장.
//   목표는 "최소한의 앨범이 실제로 저장되어 목록·상세에 뜨고,
//   saveAlbum → flush → 서버 순환이 실데이터로 검증되는 것".
//
// 설계 전제(확정):
//   · AlbumDraft 계층을 두지 않는다 — 화면 상태에서 바로 Album 애그리게이트를
//     조립해 saveAlbum에 넘긴다. (Draft는 대 2 자동입력에서 필요해지면)
//   · 클라이언트 UUID는 화면에서 생성한다. 연주자·수록곡은 행/카드를 추가하는
//     그 자리에서 id를 확정하고, 앨범 id는 저장 시점에 발급한다.
//   · 신규 등록 전용. 모든 수록곡은 앨범 기본 연주자를 상속한다
//     (performerOverrides = null — 빈 리스트가 아니다. §3-2 상속 규칙).
//
// UI: 스텝퍼 대신 단일 스크롤 + 섹션 헤더 4개(뼈대 단계라 단순하게).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/album.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

/// 포맷 선택지 — albums.format은 자유 텍스트지만 입력은 이 넷으로 제한한다.
const _formats = ['CD', 'LP', 'SACD', 'digital'];

class AddAlbumScreen extends ConsumerStatefulWidget {
  const AddAlbumScreen({super.key});

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
  // 빈 카드 하나로 시작한다. 끝까지 비어 있으면 저장 시 조용히 버린다.
  final List<_CompositionCard> _compositions = [_CompositionCard()];

  // ── Step 4. 사용자 정보 ──
  DateTime? _acquiredAt;
  final _location = TextEditingController();
  final _review = TextEditingController();

  bool _saving = false;

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

    // 수록곡 조립 — 완전히 빈 카드는 버리고, 내용은 있는데 작곡가만 빈 카드는 막는다.
    // (조용히 버리면 사용자가 입력한 정보가 소리 없이 사라진다)
    final compositions = <Composition>[];
    for (var i = 0; i < _compositions.length; i++) {
      final card = _compositions[i];
      if (card.isBlank) continue;
      if (card.composer.text.trim().isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text('${i + 1}번째 수록곡의 작곡가를 입력해 주세요')),
        );
        return;
      }
      compositions.add(Composition(
        id: card.id,
        composer: card.composer.text.trim(),
        catalogNumber: _nullIfEmpty(card.catalogNumber.text),
        discNo: int.tryParse(card.discNo.text.trim()),
        trackFrom: int.tryParse(card.trackFrom.text.trim()),
        trackTo: int.tryParse(card.trackTo.text.trim()),
        seq: compositions.length, // 카드 순서 = seq (0, 1, 2…)
        // 사용자가 직접 입력한 값이므로 confirmed.
        // 자동입력(대 2)이 생기면 그 경로만 unverified로 들어온다.
        confidence: Confidence.confirmed,
        movements: const [], // TODO: 2B-2b — 악장 입력
        performerOverrides: null, // 앨범 기본값 상속 (§3-2)
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

    final album = Album(
      id: _uuid.v4(), // 앨범 id는 저장 시점에 확정
      title: title,
      label: _nullIfEmpty(_label.text),
      releaseYear: int.tryParse(_releaseYear.text.trim()),
      discCount: int.tryParse(_discCount.text.trim()) ?? 1,
      format: _format,
      barcode: null, // TODO: 2B-2b — 바코드 스캔(§4-3 중복 감지)
      coverUrl: null, // TODO: 2B-2b — 커버 촬영·업로드
      location: _nullIfEmpty(_location.text),
      review: _nullIfEmpty(_review.text),
      acquiredAt: _acquiredAt,
      disposedAt: null, // 등록 시점은 언제나 소장중 (§6-2)
      defaultPerformers: performers,
      compositions: compositions,
    );

    setState(() => _saving = true);
    try {
      // 오프라인이어도 로컬 커밋 후 큐에 쌓이므로 여기서 온라인을 따지지 않는다.
      await ref.read(collectionRepositoryProvider).saveAlbum(album);
      if (!mounted) return;
      // 목록은 albumSummariesProvider(Drift watch)라 invalidate 없이 갱신된다.
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('「$title」 등록됨')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('저장 실패: $e')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('음반 등록'),
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
            _Field(
              controller: _title,
              label: '제목 *',
              hint: '예: Goldberg Variations',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _label,
              label: '레이블',
              hint: '예: Deutsche Grammophon',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _releaseYear,
                    label: '발매연도',
                    hint: '예: 1981',
                    numeric: true,
                    maxLength: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
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
            // TODO: 2B-2b — 곡별 연주자 override(상속 예외) 입력
            ..._performers.map(_buildPerformerRow),
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
            // TODO: 2B-2b — 6곡 이상이면 표 전환 (§4-3)
            // TODO: 2B-2b — 세트(전집) 일괄 추가
            // TODO: 2B-2b — Work 매칭·자동완성은 대 2
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
            _Field(
              controller: _location,
              label: '보관 위치',
              hint: '예: 거실 선반 2단',
            ),
            const SizedBox(height: 12),
            _Field(
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

  // ── Step 2 행 ──
  Widget _buildPerformerRow(_PerformerRow row) {
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
            child: _Field(controller: row.name, hint: '이름'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            tooltip: '삭제',
            onPressed: () => setState(() {
              _performers.remove(row);
              row.dispose();
            }),
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
          _Field(
            controller: card.composer,
            label: '작곡가 *',
            hint: '예: J.S. Bach',
            onChanged: (_) => setState(() {}), // 빈 카드 판정 갱신
          ),
          const SizedBox(height: 10),
          _Field(
            controller: card.catalogNumber,
            label: '작품번호',
            hint: '예: BWV 988',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: card.discNo,
                  label: '디스크',
                  numeric: true,
                  maxLength: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Field(
                  controller: card.trackFrom,
                  label: '시작 트랙',
                  numeric: true,
                  maxLength: 3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Field(
                  controller: card.trackTo,
                  label: '끝 트랙',
                  numeric: true,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          // TODO: 2B-2b — 악장(Movement) 목록 입력
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
  final String id = _uuid.v4();
  PerformerRole role = PerformerRole.conductor;
  final TextEditingController name = TextEditingController();

  void dispose() => name.dispose();
}

class _CompositionCard {
  final String id = _uuid.v4();
  final TextEditingController composer = TextEditingController();
  final TextEditingController catalogNumber = TextEditingController();
  final TextEditingController discNo = TextEditingController();
  final TextEditingController trackFrom = TextEditingController();
  final TextEditingController trackTo = TextEditingController();

  /// 아무것도 입력하지 않은 카드 — 저장 시 조용히 버린다.
  bool get isBlank =>
      composer.text.trim().isEmpty &&
      catalogNumber.text.trim().isEmpty &&
      discNo.text.trim().isEmpty &&
      trackFrom.text.trim().isEmpty &&
      trackTo.text.trim().isEmpty;

  void dispose() {
    composer.dispose();
    catalogNumber.dispose();
    discNo.dispose();
    trackFrom.dispose();
    trackTo.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공용 위젯
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool numeric;
  final int? maxLength;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    this.label,
    this.hint,
    this.numeric = false,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onChanged: onChanged,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters:
          numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: AppColors.cream, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '', // maxLength 글자수 카운터 숨김
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

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
