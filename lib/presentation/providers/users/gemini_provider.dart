import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../gemini_provider.g.dart';

@riverpod
types.User geminiUser(Ref ref) {
  final geminiUser = types.User(
    id: 'gemini-id',
    firstName: 'Gemini',
    imageUrl: 'https://picsum.photos/id/177/200/200',
  );

  return geminiUser;
}
