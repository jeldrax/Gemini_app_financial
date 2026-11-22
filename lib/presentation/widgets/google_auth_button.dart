import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Línea divisoria horizontal con texto centrado (`o`) para separar el acceso con correo del acceso con Google.
/// Toma los colores automáticamente de tu tema oscuro (`AppTheme`).
class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, this.label = 'o'});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
              thickness: 1,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón secundario en forma de píldora para iniciar sesión o registrarse con Google.
/// Mantiene el Dark Mode de `AppTheme` y usa el ícono oficial de Google desde Font Awesome.
class GoogleAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const GoogleAuthButton({
    super.key,
    this.label = 'Continuar con Google',
    this.isLoading = false,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isInteractive = enabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isInteractive ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh,
          disabledBackgroundColor: colorScheme.surfaceContainerHigh.withValues(
            alpha: 0.6,
          ),
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: colorScheme.onSurface,
                  strokeWidth: 2.2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
