import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gemini_app/presentation/providers/auth/google_auth_service.dart';
import 'package:gemini_app/presentation/widgets/google_auth_button.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' hide RadialGradient;

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  static const _ctaBackground = Colors.white;
  static const _ctaForeground = Colors.black;
  static const _glowEmerald = Color(0xFF10B981);

  static const _riveAssetPath = 'assets/7166-13754-money.riv';
  static const _riveStateMachineName = 'State Machine 1';
  static const _riveFallbackAnimation = 'Timeline 1';

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{6,}$');

  bool _obscureText = true;
  bool _isLoading = false;
  bool? _isGoogleLoading;

  bool get _googleLoading => _isGoogleLoading ?? false;

  RiveAnimationController? _riveController;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _emailError;
  String? _passError;

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email);

  bool _isValidPassword(String pass) => _passwordRegex.hasMatch(pass);

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
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.errorContainer,
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  void _onRiveInit(Artboard artboard) {
    final stateMachine = StateMachineController.fromArtboard(
      artboard,
      _riveStateMachineName,
    );
    if (stateMachine != null) {
      artboard.addController(stateMachine);
      _riveController = stateMachine;
      return;
    }

    final fallback = SimpleAnimation(_riveFallbackAnimation);
    artboard.addController(fallback);
    _riveController = fallback;
  }

  Future<void> _onLogin() async {
    if (_isLoading || _googleLoading) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    final eError = _isValidEmail(email)
        ? null
        : 'Formato de correo electrónico inválido';
    final pError = _isValidPassword(pass)
        ? null
        : 'Mínimo 6 caracteres con letras y números';

    setState(() {
      _emailError = eError;
      _passError = pError;
    });

    FocusScope.of(context).unfocus();

    if (eError != null || pError != null) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      _showErrorSnackBar('Firebase no está inicializado correctamente.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // Cuando Firebase inicia sesión, GoRouter redirige automáticamente a `/`.
    } on FirebaseAuthException catch (e) {
      final errorMessage = _mapAuthError(e);
      if (mounted) {
        setState(() {
          _passError = errorMessage;
        });
        _showErrorSnackBar(errorMessage);
      }
    } catch (_) {
      _showErrorSnackBar('Ocurrió un error inesperado al iniciar sesión.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onGoogleSignIn() async {
    if (_isLoading || _googleLoading) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isGoogleLoading = true;
      _emailError = null;
      _passError = null;
    });

    try {
      final result = await GoogleAuthService.signInWithGoogle();
      if (!mounted) return;
      if (result.errorMessage != null) {
        _showErrorSnackBar(result.errorMessage!);
      }
      // Si el acceso con Google fue exitoso, GoRouter redirige automáticamente a `/`.
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final resetCtrl = TextEditingController(text: _emailCtrl.text.trim());
    String? dialogError;
    final colorScheme = Theme.of(context).colorScheme;

    final confirmedEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          title: const Text('Recuperar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa el correo asociado a tu cuenta para enviarte un enlace de restablecimiento.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: _buildInputDecoration(
                  colorScheme: colorScheme,
                  hintText: 'nombre@ejemplo.com',
                  errorText: dialogError,
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
                if (!_isValidEmail(candidate)) {
                  setDialogState(() {
                    dialogError = 'Ingresa un correo válido';
                  });
                  return;
                }
                Navigator.pop(ctx, candidate);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _ctaBackground,
                foregroundColor: _ctaForeground,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
          behavior: SnackBarBehavior.floating,
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

  InputDecoration _buildInputDecoration({
    required ColorScheme colorScheme,
    required String hintText,
    String? errorText,
    Widget? suffixIcon,
  }) {
    const baseRadius = BorderRadius.all(Radius.circular(16));

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 15,
      ),
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: baseRadius,
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: baseRadius,
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: baseRadius,
        borderSide: BorderSide(color: colorScheme.onSurface, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: baseRadius,
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: baseRadius,
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
      ),
    );
  }

  Widget _buildRiveHeroSlot() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 184,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Brillo esmeralda detrás de la animación
              Container(
                width: 220,
                height: 184,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _glowEmerald.withValues(alpha: 0.20),
                      _glowEmerald.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              SizedBox(
                width: 176,
                height: 176,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RiveAnimation.asset(
                    _riveAssetPath,
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emblema hexagonal superior izquierdo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size(20, 20),
            painter: _VaultEmblemPainter(color: colorScheme.onSurface),
          ),
        ),
        _buildRiveHeroSlot(),
        Text(
          'Iniciar sesión',
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Accede a tus cuentas y finanzas de forma segura.',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.45,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme colorScheme, TextTheme textTheme) {
    final labelStyle = textTheme.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: colorScheme.onSurface.withValues(alpha: 0.85),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Correo electrónico', style: labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
            decoration: _buildInputDecoration(
              colorScheme: colorScheme,
              hintText: 'nombre@ejemplo.com',
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contraseña', style: labelStyle),
              TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            focusNode: _passwordFocus,
            obscureText: _obscureText,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
            onSubmitted: (_) => _onLogin(),
            onChanged: (_) {
              if (_passError != null) {
                setState(() => _passError = null);
              }
            },
            decoration: _buildInputDecoration(
              colorScheme: colorScheme,
              hintText: 'Ingresa tu contraseña',
              errorText: _passError,
              suffixIcon: IconButton(
                tooltip: _obscureText
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _ctaBackground,
                foregroundColor: _ctaForeground,
                disabledBackgroundColor: _ctaBackground.withValues(alpha: 0.65),
                disabledForegroundColor: _ctaForeground,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              onPressed: (_isLoading || _googleLoading) ? null : _onLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _ctaForeground,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
          const AuthOrDivider(),
          GoogleAuthButton(
            label: 'Continuar con Google',
            isLoading: _googleLoading,
            enabled: !_isLoading,
            onPressed: _onGoogleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes una cuenta?',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colorScheme.onSurface,
            ),
            child: Text(
              'Regístrate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 430,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(colorScheme, textTheme),
                            _buildLoginForm(colorScheme, textTheme),
                          ],
                        ),
                        _buildFooter(colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
    _riveController?.dispose();
    super.dispose();
  }
}

/// Dibuja el emblema hexagonal 
class _VaultEmblemPainter extends CustomPainter {
  final Color color;

  const _VaultEmblemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * sx
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final hexagon = Path()
      ..moveTo(12 * sx, 2 * sy)
      ..lineTo(3 * sx, 7 * sy)
      ..lineTo(3 * sx, 17 * sy)
      ..lineTo(12 * sx, 22 * sy)
      ..lineTo(21 * sx, 17 * sy)
      ..lineTo(21 * sx, 7 * sy)
      ..close();

    canvas.drawPath(hexagon, paint);
    canvas.drawCircle(Offset(12 * sx, 12 * sy), 3 * sx, paint);
  }

  @override
  bool shouldRepaint(covariant _VaultEmblemPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
