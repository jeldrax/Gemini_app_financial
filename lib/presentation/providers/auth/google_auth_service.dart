import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Outcome of a Google Sign-In / Sign-Up attempt via Firebase Authentication.
class GoogleAuthResult {
  final UserCredential? credential;
  final bool cancelled;
  final String? errorMessage;

  const GoogleAuthResult._({
    this.credential,
    this.cancelled = false,
    this.errorMessage,
  });

  const GoogleAuthResult.success(UserCredential credential)
      : this._(credential: credential);

  const GoogleAuthResult.cancelled() : this._(cancelled: true);

  const GoogleAuthResult.failure(String message)
      : this._(errorMessage: message);

  bool get isSuccess => credential != null;
}

/// Shared service to sign in or automatically register users with Google
/// through Firebase Authentication (`signInWithPopup` on Web, `signInWithProvider` on mobile).
class GoogleAuthService {
  const GoogleAuthService._();

  static const _cancelledErrorCodes = <String>{
    'web-context-canceled',
    'popup-closed-by-user',
    'cancelled-popup-request',
    'canceled',
    'user-cancelled',
  };

  static Future<GoogleAuthResult> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) {
      return const GoogleAuthResult.failure(
        'Firebase no está inicializado correctamente.',
      );
    }

    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});

    try {
      final UserCredential credential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);
      return GoogleAuthResult.success(credential);
    } on FirebaseAuthException catch (e) {
      if (_cancelledErrorCodes.contains(e.code)) {
        return const GoogleAuthResult.cancelled();
      }
      return GoogleAuthResult.failure(_mapGoogleAuthError(e));
    } on UnsupportedError {
      return const GoogleAuthResult.failure(
        'El inicio de sesión con Google no está disponible en esta plataforma.',
      );
    } catch (_) {
      return const GoogleAuthResult.failure(
        'No se pudo completar la autenticación con Google.',
      );
    }
  }

  static String _mapGoogleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método de acceso.';
      case 'operation-not-allowed':
        return 'El acceso con Google no está habilitado en Firebase.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      case 'popup-blocked':
        return 'El navegador bloqueó la ventana emergente de Google.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';
      default:
        return e.message ?? 'Error al continuar con Google.';
    }
  }
}
