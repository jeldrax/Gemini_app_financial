// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_gemini_writing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsGeminiwriting)
final isGeminiwritingProvider = IsGeminiwritingProvider._();

final class IsGeminiwritingProvider
    extends $NotifierProvider<IsGeminiwriting, bool> {
  IsGeminiwritingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isGeminiwritingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isGeminiwritingHash();

  @$internal
  @override
  IsGeminiwriting create() => IsGeminiwriting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isGeminiwritingHash() => r'ce1bfb5c749fbd7ee097f609d74ea4127d9e2605';

abstract class _$IsGeminiwriting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
