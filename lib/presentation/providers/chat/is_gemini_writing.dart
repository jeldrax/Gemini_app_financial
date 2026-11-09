import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_gemini_writing.g.dart';

@riverpod
class IsGeminiwriting extends _$IsGeminiwriting {
  @override
  bool build() => false;

  void setIsGeminiWriting() {
    state = true;
  }

  void setIsNotGeminiWriting() {
    state = false;
  }
}
