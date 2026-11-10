import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart'; //?Podemos afgregar un show message de gemini escribiendo para que solo muestre el mensaje y asi optimizarlo a no mostrar el mensaje de gemini escribiendo y que solo se muestre el mensaje cuando gemini ya haya terminado de escribir

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {
  @override
  List<types.Message> build() {
    return [];
  }

  void addMessage({
    required types.PartialText partialText,
    required types.User user,
  }) {
    //todo: agregar condicion cuando vengan imagenes

    _addTextMessage(partialText, user);
  }

  void _addTextMessage(types.PartialText partialText, types.User author) {
    final message = types.TextMessage(
      id: uuid.v4(),
      author: author,
      text: partialText.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }
}
