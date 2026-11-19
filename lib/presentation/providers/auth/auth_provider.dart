import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Firebase has been initialized in the current app lifecycle.
final firebaseInitializedProvider = Provider<bool>((ref) {
  return Firebase.apps.isNotEmpty;
});

/// Emits Firebase authentication state changes, or `null` if Firebase is not initialized.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<User?>.value(null);
  }
  return FirebaseAuth.instance.authStateChanges();
});

/// Temporarily holds GoRouter redirects on `/login` so the Rive success animation can finish.
class AuthRedirectHoldNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void hold() => state = true;

  void release() => state = false;
}

final authRedirectHoldProvider =
    NotifierProvider<AuthRedirectHoldNotifier, bool>(
      AuthRedirectHoldNotifier.new,
    );
