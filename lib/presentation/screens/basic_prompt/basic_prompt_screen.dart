import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//PROVIDERS ===USER Y GEMINI USER===
import 'package:gemini_app/presentation/providers/gemini_provider.dart';
import 'package:gemini_app/presentation/providers/user_provider.dart';

class BasicPromptScreen extends ConsumerWidget {
  const BasicPromptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final geminiUser = ref.watch(geminiUserProvider);

    final messages = <types.Message>[
      // types.TextMessage(author: user, id: '1', text: 'Hola Mundo'),
      // types.TextMessage(author: user, id: '2', text: 'Hola Mundo 2'),
      // types.TextMessage(author: geminiUser, id: '3', text: 'Hola Mundo 3'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Básico')),
      body: Chat(
        messages: [],
        onSendPressed: (types.PartialText partialText) {
          print('mensaje: ${partialText.text}');
        },
        user: user,
        theme: const DarkChatTheme(),
        showUserNames: true,
        // showUserAvatars: true,
        typingIndicatorOptions: TypingIndicatorOptions(
          //typingUsers: [geminiUser],
          customTypingWidget: const Center(
            child: Text('Gemini está pensando...'),
          ),
        ),
      ),
    );
  }
}
