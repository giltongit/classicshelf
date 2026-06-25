import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../providers/cover_upload_provider.dart';
import '../providers/providers.dart';
import '../repositories/book_repository.dart';
import '../services/cover_photo_service.dart';
import '../theme/app_theme.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  /// null이면 신규 추가, 값이 있으면 수정 모드.
  final Book? editBook;

  /// 바코드 스캔 검색 결과 — 신규 추가 시 폼 자동입력에 사용.
  final BookSearchResult? searchResult;

  const AddBookScreen({super.key, this.editBook, this.searchResult});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photoService = CoverPhotoService();

  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _isbn;
  late final TextEditingController _publisher;
  late final TextEditingController _year;
  late final TextEditingController _genre;
  late final TextEditingController _location;
  late final TextEditingController _callNumber;
  late final TextEditingController _review;

  late String _status;
  bool _isRead = false;
  String _medium = 'paper';
  File? _localCoverFile;
  String? _coverUrl;
  bool _saving = false;

  bool get _isEdit => widget.editBook != null;

  @override
  void initState() {
    super.initState();
    final b = widget.editBook;
    final s = widget.searchResult;
    _title      = TextEditingController(text: b?.title     ?? s?.title     ?? '');
    _author     = TextEditingController(text: b?.author    ?? s?.author    ?? '');
    _isbn       = TextEditingController(text: b?.isbn      ?? s?.isbn      ?? '');
    _publisher  = TextEditingController(text: b?.publisher ?? s?.publisher ?? '');
    _year       = TextEditingController(text: b?.year      ?? s?.year      ?? '');
    _genre      = TextEditingController(text: b?.genre     ?? s?.genre     ?? '');
    _location   = TextEditingController(text: b?.location  ?? '');
    _callNumber = TextEditingController(text: b?.callNumber ?? '');
    _review     = TextEditingController(text: b?.review    ?? '');
    _status     = b?.status ?? 'owned';
    _isRead     = b?.isRead ?? false;
    _medium     = b?.medium ?? 'paper';
    _coverUrl   = b?.coverUrl ?? s?.thumbnailUrl;
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _isbn.dispose();
    _publisher.dispose();
    _year.dispose();
    _genre.dispose();
    _location.dispose();
    _callNumber.dispose();
    _review.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final file = await _photoService.pickFromCamera();
    if (file == null || !mounted) return;
    setState(() => _localCoverFile = file);
  }

  Future<void> _pickFromGallery() async {
    final file = await _photoService.pickFromGallery();
    if (file == null || !mounted) return;
    setState(() => _localCoverFile = file);
  }

  String? _nonEmpty(String key) {
    final v = switch (key) {
      'isbn'       => _isbn.text.trim(),
      'publisher'  => _publisher.text.trim(),
      'year'       => _year.text.trim(),
      'genre'      => _genre.text.trim(),
      'location'   => _location.text.trim(),
      'callNumber' => _callNumber.text.trim(),
      'review'     => _review.text.trim(),
      _            => '',
    };
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // ISBN 중복 체크 (신규 추가 시)
    if (!_isEdit) {
      final isbn = _nonEmpty('isbn');
      if (isbn != null) {
        final repo = ref.read(bookRepositoryProvider);
        final books = await repo.getBooks();
        final dup = books.where((b) => b.isbn == isbn).firstOrNull;
        if (dup != null && mounted) {
          await _showDuplicateDialog(dup);
          return;
        }
      }
    }

    setState(() => _saving = true);

    try {
      final repo   = ref.read(bookRepositoryProvider);
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

      if (_isEdit) {
        // 수정 모드
        Book result = await repo.updateBook(widget.editBook!.copyWith(
          title:      _title.text.trim(),
          author:     _author.text.trim(),
          isbn:       _nonEmpty('isbn'),
          publisher:  _nonEmpty('publisher'),
          year:       _nonEmpty('year'),
          genre:      _nonEmpty('genre'),
          location:   _nonEmpty('location'),
          callNumber: _nonEmpty('callNumber'),
          review:     _nonEmpty('review'),
          status:     _status,
          isRead:     _isRead,
          medium:     _medium,
          coverUrl:   _coverUrl,
        ));

        if (_localCoverFile != null) {
          result = await _uploadCover(repo, userId, _localCoverFile!, result);
        }
      } else {
        // 신규 추가: Supabase가 uuid 생성 → addBook 반환값에서 supabaseId/localId 확보
        Book created = await repo.addBook(Book(
          userId:     userId,
          title:      _title.text.trim(),
          author:     _author.text.trim(),
          isbn:       _nonEmpty('isbn'),
          publisher:  _nonEmpty('publisher'),
          year:       _nonEmpty('year'),
          genre:      _nonEmpty('genre'),
          location:   _nonEmpty('location'),
          callNumber: _nonEmpty('callNumber'),
          review:     _nonEmpty('review'),
          status:     _status,
          isRead:     _isRead,
          medium:     _medium,
          coverUrl:   _coverUrl, // thumbnailUrl(scan) 또는 null
        ));
        debugPrint('[SAVE] addBook 반환: localId=${created.localId} supabaseId=${created.supabaseId}');

        if (_localCoverFile != null) {
          debugPrint('[SAVE] 표지 파일 있음 → _uploadCover 호출');
          await _uploadCover(repo, userId, _localCoverFile!, created);
        } else {
          debugPrint('[SAVE] 표지 파일 없음 → _uploadCover 생략');
        }
      }

      ref.invalidate(booksProvider);
      try { await ref.read(booksProvider.future); } catch (_) {}
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showDuplicateDialog(Book existing) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            SizedBox(width: 8),
            Text('이미 등록된 책'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('같은 ISBN의 책이 이미 등록되어 있습니다.',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dim),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existing.title,
                      style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(existing.author,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              if (mounted) {
                context.pop();
                context.push('/books/${existing.localId}');
              }
            },
            child: const Text('기존 책 보기',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 표지 업로드 → coverUrl 업데이트 → 갱신된 Book 반환.
  ///
  /// 흐름: pick(호출 전) → resizeAndCache → CoverUploadNotifier.enqueue
  ///   온라인: Storage 업로드 성공 → public URL → updateBook
  ///   오프라인: 펜딩 큐 적재 + 로컬 경로를 임시 coverUrl로 저장 → 화면에 즉시 표시
  Future<Book> _uploadCover(
    BookRepository repo,
    String userId,
    File localFile,
    Book book,
  ) async {
    // supabaseId 없으면(오프라인 추가) localId를 임시 bookId로 사용
    final bookId = book.supabaseId ?? book.localId!.toString();
    debugPrint('[COVER] _uploadCover 시작: bookId=$bookId supabaseId=${book.supabaseId}');

    // ① 리사이즈
    final resized = await _photoService.resizeAndCache(localFile, bookId);
    debugPrint('[COVER] 리사이즈 완료 → enqueue: ${resized.path}');

    // ② enqueue: 온라인=즉시 업로드, 오프라인=펜딩 큐 적재
    final url = await ref.read(coverUploadProvider.notifier).enqueue(
      file: resized,
      userId: userId,
      bookId: bookId,
    );
    debugPrint('[COVER] enqueue 결과: ${url ?? "오프라인 큐 적재"}');

    if (url != null) {
      // 온라인: Storage public URL을 coverUrl에 반영
      debugPrint('[COVER] updateBook 호출: supabaseId=${book.supabaseId} coverUrl=$url');
      return await repo.updateBook(book.copyWith(coverUrl: url));
    } else {
      // 오프라인: 로컬 경로를 임시 coverUrl로 저장 → 목록/상세에서 즉시 표시
      debugPrint('[COVER] updateBook 호출(오프라인): supabaseId=${book.supabaseId} coverUrl=${resized.path}');
      return await repo.updateBook(book.copyWith(coverUrl: resized.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '책 수정' : '책 추가')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverPicker(
                  localFile: _localCoverFile,
                  coverUrl: _coverUrl,
                  onCamera: _pickFromCamera,
                  onGallery: _pickFromGallery,
                ),
                const SizedBox(height: 20),
                _StatusToggle(
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SizedBox(height: 4),
                _MediumSelector(
                  value: _medium,
                  onChanged: (v) => setState(() => _medium = v),
                ),
                const SizedBox(height: 12),
                _Field(controller: _title,     label: '제목 *',  validator: _requiredValidator),
                _Field(controller: _author,    label: '저자 *',  validator: _requiredValidator),
                _Field(controller: _isbn,      label: 'ISBN',   keyboardType: TextInputType.number),
                _Field(controller: _publisher, label: '출판사'),
                _Field(controller: _year,      label: '출판연도', keyboardType: TextInputType.number),
                _Field(controller: _genre,     label: '장르'),
                _Field(controller: _location,   label: '책장 위치'),
                _Field(controller: _callNumber, label: '청구기호',
                    hint: '예) 813.6-한강-채'),
                SwitchListTile(
                  title: const Text('읽은 책',
                      style: TextStyle(color: AppColors.cream, fontSize: 14)),
                  value: _isRead,
                  onChanged: (v) => setState(() => _isRead = v),
                  activeThumbColor: AppColors.gold,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                _Field(controller: _review,    label: '메모', maxLines: 3),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.bg,
                          ),
                        )
                      : Text(_isEdit ? '수정 저장' : '저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? '필수 항목입니다' : null;
}

// ── 하위 위젯 ──────────────────────────────────────────────────────────────────

class _CoverPicker extends StatelessWidget {
  final File? localFile;
  final String? coverUrl;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _CoverPicker({
    required this.localFile,
    required this.coverUrl,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onCamera,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dim),
              ),
              clipBehavior: Clip.antiAlias,
              child: localFile != null
                  ? Image.file(localFile!, fit: BoxFit.cover)
                  : coverUrl != null
                      ? (coverUrl!.startsWith('http')
                          ? Image.network(coverUrl!, fit: BoxFit.cover)
                          : Image.file(File(coverUrl!), fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.muted, size: 32),
                            SizedBox(height: 8),
                            Text(
                              '표지 촬영',
                              style: TextStyle(color: AppColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('카메라'),
              ),
              TextButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('갤러리'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.cream),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}

class _MediumSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _MediumSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Text('매체', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(width: 12),
          ToggleButtons(
            isSelected: [value == 'paper', value == 'ebook', value == 'audio'],
            onPressed: (i) => onChanged(['paper', 'ebook', 'audio'][i]),
            borderRadius: BorderRadius.circular(8),
            selectedColor: AppColors.bg,
            fillColor: AppColors.gold,
            color: AppColors.muted,
            borderColor: AppColors.dim,
            selectedBorderColor: AppColors.gold,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            constraints: const BoxConstraints(minHeight: 36, minWidth: 68),
            children: const [Text('종이책'), Text('전자책'), Text('오디오북')],
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isOwned = value == 'owned';
    return Row(
      children: [
        const Text('상태', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(width: 12),
        ToggleButtons(
          isSelected: [isOwned, value == 'wishlist', value == 'rental'],
          onPressed: (i) => onChanged(['owned', 'wishlist', 'rental'][i]),
          borderRadius: BorderRadius.circular(8),
          selectedColor: AppColors.bg,
          fillColor: AppColors.gold,
          color: AppColors.muted,
          borderColor: AppColors.dim,
          selectedBorderColor: AppColors.gold,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          constraints: const BoxConstraints(minHeight: 36, minWidth: 68),
          children: const [Text('소장'), Text('희망'), Text('대여')],
        ),
      ],
    );
  }
}
