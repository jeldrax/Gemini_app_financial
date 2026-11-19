import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

/// Animated Rive bear login screen backed by Firebase Authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _bearBackgroundColor = Color(0xFFD6E2EA);
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{6,}$');

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Anti-spam lock while the bear responds to toggling Remember Me.
  bool _isAnimatingToggle = false;
  Timer? _toggleLockTimer;

  // Rive state machine controller and inputs.
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  Timer? _typingDebounce;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? emailError;
  String? passError;

  bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  bool isValidPassword(String pass) => _passwordRegex.hasMatch(pass);

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo y contraseña no está habilitado en Firebase.';
      default:
        return e.message ?? 'Error al iniciar sesión.';
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        backgroundColor: colorScheme.errorContainer,
      ),
    );
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    final eError = isValidEmail(email)
        ? null
        : 'Formato de correo electrónico inválido';
    final pError = isValidPassword(pass)
        ? null
        : 'Mínimo 6 caracteres con letras y números';

    setState(() {
      emailError = eError;
      passError = pError;
    });

    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    if (eError != null || pError != null) {
      _trigFail?.fire();
      return;
    }

    if (Firebase.apps.isEmpty) {
      _trigFail?.fire();
      _showErrorSnackBar('Firebase no está inicializado correctamente.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final redirectHold = ref.read(authRedirectHoldProvider.notifier);
    // Keep `/login` visible long enough for the bear celebration animation.
    redirectHold.hold();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      _trigSuccess?.fire();
      await Future.delayed(const Duration(milliseconds: 1000));
      redirectHold.release();
    } on FirebaseAuthException catch (e) {
      redirectHold.release();
      _trigFail?.fire();

      final errorMessage = _mapAuthError(e);
      if (mounted) {
        setState(() {
          passError = errorMessage;
        });
        _showErrorSnackBar(errorMessage);
      }
    } catch (_) {
      redirectHold.release();
      _trigFail?.fire();
      _showErrorSnackBar('Ocurrió un error inesperado al iniciar sesión.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onToggleRememberMe(bool? value) {
    if (_isAnimatingToggle) return;

    setState(() {
      _isAnimatingToggle = true;
      _rememberMe = value ?? false;
    });

    FocusScope.of(context).unfocus();
    _isHandsUp?.change(false);
    _isChecking?.change(true);
    _numLook?.value = 50.0;

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _isChecking?.change(false);
    });

    _toggleLockTimer?.cancel();
    _toggleLockTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isAnimatingToggle = false;
      });
    });
  }

  Future<void> _forgotPassword() async {
    final resetCtrl = TextEditingController(text: _emailCtrl.text.trim());
    String? dialogError;

    final confirmedEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa el correo asociado a tu cuenta para enviarte un enlace de restablecimiento.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resetCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: dialogError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final candidate = resetCtrl.text.trim();
                if (!isValidEmail(candidate)) {
                  setDialogState(() {
                    dialogError = 'Ingresa un correo válido';
                  });
                  return;
                }
                Navigator.pop(ctx, candidate);
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );

    resetCtrl.dispose();

    if (confirmedEmail == null || !mounted) return;

    if (Firebase.apps.isEmpty) {
      _showErrorSnackBar('Firebase no está inicializado correctamente.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: confirmedEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo está registrado, recibirás un enlace para restablecer tu contraseña (revisa tu bandeja o spam).',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapAuthError(e));
    } catch (_) {
      _showErrorSnackBar('No se pudo enviar el correo de recuperación.');
    }
  }

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus && _isHandsUp != null) {
        _isHandsUp?.change(false);
        _numLook?.value = 50.0;
      }
    });

    _passwordFocus.addListener(() {
      if (_isHandsUp != null) {
        _isHandsUp?.change(_passwordFocus.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: size.width,
                  height: 210,
                  color: _bearBackgroundColor,
                  child: RiveAnimation.asset(
                    'assets/login-bear.riv',
                    stateMachines: const ['Login Machine'],
                    fit: BoxFit.contain,
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      if (_controller == null) return;
                      artboard.addController(_controller!);

                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (_isChecking == null) return;
                  _isChecking!.change(true);

                  final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  _numLook?.value = look;

                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    if (!mounted) return;
                    _isChecking?.change(false);
                  });
                },
                decoration: InputDecoration(
                  errorText: emailError,
                  hintText: 'Email',
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passCtrl,
                focusNode: _passwordFocus,
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onLogin(),
                onChanged: (_) {
                  if (_isHandsUp == null) return;
                  _isHandsUp!.change(true);
                },
                decoration: InputDecoration(
                  errorText: passError,
                  hintText: 'Password',
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AbsorbPointer(
                    absorbing: _isAnimatingToggle,
                    child: GestureDetector(
                      onTap: () => _onToggleRememberMe(!_rememberMe),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: _onToggleRememberMe,
                          ),
                          Text(
                            'Recordarme',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: size.width,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onLogin,
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel();
    _toggleLockTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
