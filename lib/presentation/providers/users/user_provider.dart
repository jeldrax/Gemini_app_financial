import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:gemini_app/presentation/providers/auth/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../user_provider.g.dart';

@riverpod
types.User user(Ref ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final firebaseUser =
      authAsync.asData?.value ??
      (Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null);

  final displayName = firebaseUser?.displayName?.trim();
  final email = firebaseUser?.email?.trim();
  final emailPrefix = (email != null && email.contains('@'))
      ? email.split('@').first
      : email;

  final firstName = (displayName != null && displayName.isNotEmpty)
      ? displayName
      : ((emailPrefix != null && emailPrefix.isNotEmpty)
            ? emailPrefix
            : 'Usuario');

  return types.User(
    id: firebaseUser?.uid ?? 'user-id-abc',
    firstName: firstName,
    imageUrl:
        firebaseUser?.photoURL ?? 'https://picsum.photos/id/177/200/200',
  );
}
