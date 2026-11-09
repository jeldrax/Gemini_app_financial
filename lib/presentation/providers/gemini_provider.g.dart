// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users/gemini_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiUser)
final geminiUserProvider = GeminiUserProvider._();

final class GeminiUserProvider
    extends $FunctionalProvider<types.User, types.User, types.User>
    with $Provider<types.User> {
  GeminiUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiUserHash();

  @$internal
  @override
  $ProviderElement<types.User> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  types.User create(Ref ref) {
    return geminiUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(types.User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<types.User>(value),
    );
  }
}

String _$geminiUserHash() => r'425ac091247ca9c09990216e7bff06fbd470810c';
