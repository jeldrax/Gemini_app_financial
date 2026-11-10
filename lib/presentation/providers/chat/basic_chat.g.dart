// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BasicChat)
final basicChatProvider = BasicChatProvider._();

final class BasicChatProvider
    extends $NotifierProvider<BasicChat, List<types.Message>> {
  BasicChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'basicChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$basicChatHash();

  @$internal
  @override
  BasicChat create() => BasicChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<types.Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<types.Message>>(value),
    );
  }
}

String _$basicChatHash() => r'0d03fee78e05934a190e4b6892a074569e5982a5';

abstract class _$BasicChat extends $Notifier<List<types.Message>> {
  List<types.Message> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<types.Message>, List<types.Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<types.Message>, List<types.Message>>,
              List<types.Message>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
