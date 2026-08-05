// =============================================================================
// form_fields.dart — 폼 공용 입력 위젯
//   add_book_screen.dart 안의 private 위젯(_Field/_AutocompleteField)이었다.
//   위시 편집 시트(§17-20)가 등록 폼과 같은 작곡가→작품 자동완성을 써야 해서
//   화면 밖으로 뽑았다. 위젯 자체는 화면 상태를 모른다 — controller/focusNode/
//   조회 콜백을 전부 주입받으므로 옮기는 것으로 재사용이 성립한다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 자동완성 필드 (§3-4 Work 매칭)
//   로컬 works(참조 데이터)에서 제안한다. 참조 데이터를 아직 안 받았거나
//   조회가 실패하면 제안이 비어 그냥 평범한 TextField처럼 동작한다 —
//   자동완성은 거들 뿐이고, 자유 텍스트 입력 흐름을 절대 막지 않는다.
//
//   Autocomplete가 아니라 RawAutocomplete를 쓴 이유: 호출부가 이미 들고 있는
//   TextEditingController를 그대로 넘겨야 한다(빈 카드 판정·저장 조립이 그
//   컨트롤러를 본다). Autocomplete는 내부에서 컨트롤러를 새로 만들어 이중
//   관리가 된다.
// ─────────────────────────────────────────────────────────────────────────────

class AutocompleteField<T extends Object> extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String? hint;

  /// 입력값으로 후보를 조회한다. 실패하면 빈 목록(자동완성만 조용히 꺼진다).
  final Future<List<T>> Function(String query) search;

  /// 후보 → 입력란에 넣을 문자열.
  final String Function(T option) displayString;

  /// 후보 한 줄의 표시 위젯(부제 등을 붙일 수 있게 분리).
  final Widget Function(T option) optionBuilder;

  final void Function(T option) onSelected;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.hint,
    required this.search,
    required this.displayString,
    required this.optionBuilder,
    required this.onSelected,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: displayString,
      optionsBuilder: (value) async {
        try {
          return await search(value.text);
        } catch (_) {
          return const Iterable.empty();
        }
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, ctrl, node, onSubmit) => AppTextField(
        controller: ctrl,
        focusNode: node,
        label: label,
        hint: hint,
        autofocus: autofocus,
        onChanged: onChanged,
      ),
      optionsViewBuilder: (context, select, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: AppColors.surface2,
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            // 후보가 많아도 화면을 잡아먹지 않게 자른다.
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, i) {
                final o = options.elementAt(i);
                return InkWell(
                  onTap: () => select(o),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: optionBuilder(o),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final bool numeric;
  final int? maxLength;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.numeric = false,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
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
