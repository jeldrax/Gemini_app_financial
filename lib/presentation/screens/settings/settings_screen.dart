import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';
import 'package:gemini_app/presentation/providers/finance/finance_template_provider.dart';
import 'package:gemini_app/presentation/widgets/hermes_scaffold.dart';

/// Reactive template for the HERMES "Seguridad y Ajustes" screen (`Configuracion y seguridad.png`).
/// Base monthly budget and 50/30/20 percentages read from Riverpod state and preview live changes.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _needsPctCtrl;
  late final TextEditingController _wantsPctCtrl;
  late final TextEditingController _savingsPctCtrl;

  bool _showPercentEditor = false;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(budgetConfigProvider);
    _budgetCtrl = TextEditingController(
      text: _formatInputNumber(initial.monthlyIncome),
    );
    _needsPctCtrl = TextEditingController(text: '${initial.needsPercent}');
    _wantsPctCtrl = TextEditingController(text: '${initial.wantsPercent}');
    _savingsPctCtrl = TextEditingController(text: '${initial.savingsPercent}');
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _needsPctCtrl.dispose();
    _wantsPctCtrl.dispose();
    _savingsPctCtrl.dispose();
    super.dispose();
  }

  String _formatInputNumber(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  double get _draftIncome {
    final parsed = double.tryParse(_budgetCtrl.text.trim().replaceAll(',', '.'));
    return (parsed != null && parsed >= 0) ? parsed : 0.0;
  }

  int _parsePercent(TextEditingController ctrl, int fallback) {
    final parsed = int.tryParse(ctrl.text.trim());
    if (parsed == null) return fallback;
    return parsed.clamp(0, 100);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? colorScheme.errorContainer : null,
        content: Text(
          message,
          style: isError
              ? TextStyle(color: colorScheme.onErrorContainer)
              : null,
        ),
      ),
    );
  }

  void _applyTemplateBudget(BudgetConfig currentConfig) {
    final income = _draftIncome;
    final needsPct = _parsePercent(_needsPctCtrl, currentConfig.needsPercent);
    final wantsPct = _parsePercent(_wantsPctCtrl, currentConfig.wantsPercent);
    final savingsPct = _parsePercent(
      _savingsPctCtrl,
      currentConfig.savingsPercent,
    );

    if (income <= 0) {
      _showSnackBar('Ingresa un presupuesto mensual mayor a 0.', isError: true);
      return;
    }

    if (needsPct + wantsPct + savingsPct != 100) {
      _showSnackBar(
        'Los porcentajes deben sumar exactamente 100% (actual: ${needsPct + wantsPct + savingsPct}%).',
        isError: true,
      );
      return;
    }

    ref.read(budgetConfigProvider.notifier).updateConfig(
          monthlyIncome: income,
          needsPercent: needsPct,
          wantsPercent: wantsPct,
          savingsPercent: savingsPct,
        );

    _showSnackBar(
      'Topes actualizados en plantilla (${formatCurrency(income, decimals: 0)} • $needsPct/$wantsPct/$savingsPct). Pendiente persistir en BD.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watch(budgetConfigProvider);
    final connection = ref.watch(connectionStatusProvider);

    final double previewIncome = _draftIncome;
    final int needsPct = _parsePercent(_needsPctCtrl, config.needsPercent);
    final int wantsPct = _parsePercent(_wantsPctCtrl, config.wantsPercent);
    final int savingsPct = _parsePercent(_savingsPctCtrl, config.savingsPercent);
    final int totalPct = needsPct + wantsPct + savingsPct;
    final bool validSum = totalPct == 100;

    return HermesScaffold(
      activeTab: HermesNavTab.security,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Seguridad y Ajustes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Túnel cifrado Tailscale, presupuesto base ${config.compactSplitLabel} y protección IA.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Card 1: Conectividad Privada Tailscale (Zero-Trust)
          HermesCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _CardIconBadge(icon: Icons.hub_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Conectividad Privada Tailscale (Zero-Trust)',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Toda transmisión de datos viaja exclusivamente sobre la red cifrada WireGuard de Tailscale utilizando credenciales ofuscadas en binario (',
                      ),
                      TextSpan(
                        text: 'Env.apiUrl',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: HermesAccentColors.skyHighlight,
                        ),
                      ),
                      TextSpan(text: ' y '),
                      TextSpan(
                        text: 'Env.apiToken',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: HermesAccentColors.skyHighlight,
                        ),
                      ),
                      TextSpan(text: ').'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _showSnackBar(
                            'Prueba de latencia pendiente de conectar con el backend.',
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            foregroundColor: HermesAccentColors.primaryBlue,
                            side: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.network_check_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Probar Latencia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (connection.latencyMs != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: HermesAccentColors.primaryBlue.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: HermesAccentColors.primaryBlue.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: HermesAccentColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${connection.latencyMs} ms',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: HermesAccentColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Card 2: Presupuesto Mensual Base (Regla 50/30/20 configurable)
          HermesCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const _CardIconBadge(icon: Icons.pie_chart_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Presupuesto Mensual Base (Regla $needsPct/$wantsPct/$savingsPct)',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => _showPercentEditor = !_showPercentEditor,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: HermesAccentColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _showPercentEditor ? 'Listo' : 'Ajustar %',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Define tu presupuesto mensual base para calcular tus topes de $needsPct% Necesidades, $wantsPct% Gustos y $savingsPct% Ahorro en todos tus dispositivos.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Presupuesto Mensual Total (${config.currencyCode})',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _budgetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: '2400',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: HermesAccentColors.primaryBlue,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                // Discreet collapsible percentage editor (50 / 30 / 20 -> customizable)
                if (_showPercentEditor) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PercentMiniField(
                          label: 'Necesidades %',
                          controller: _needsPctCtrl,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PercentMiniField(
                          label: 'Gustos %',
                          controller: _wantsPctCtrl,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PercentMiniField(
                          label: 'Ahorro %',
                          controller: _savingsPctCtrl,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        validSum
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 14,
                        color: validSum
                            ? HermesAccentColors.savingsEmerald
                            : colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        validSum
                            ? 'Suma: 100%'
                            : 'Suma actual: $totalPct% (debe ser 100%)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: validSum
                              ? HermesAccentColors.savingsEmerald
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),

                // Live 3-column preview grid (50% Necesidades | 30% Gustos | 20% Ahorro)
                Row(
                  children: [
                    Expanded(
                      child: _BudgetPreviewBox(
                        label: '$needsPct%\nNecesidades',
                        amount: formatCurrency(
                          previewIncome * (needsPct / 100.0),
                          decimals: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BudgetPreviewBox(
                        label: '$wantsPct% Gustos',
                        amount: formatCurrency(
                          previewIncome * (wantsPct / 100.0),
                          decimals: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BudgetPreviewBox(
                        label: '$savingsPct% Ahorro',
                        amount: formatCurrency(
                          previewIncome * (savingsPct / 100.0),
                          decimals: 0,
                        ),
                        highlighted: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: validSum
                        ? () => _applyTemplateBudget(config)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: HermesAccentColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text(
                      'Guardar Topes',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Card 3: Arquitectura Aislada y Anti-Explotación de IA
          HermesCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const _CardIconBadge(icon: Icons.verified_user_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Arquitectura Aislada y Anti-Explotación de IA',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SecurityBulletRow(
                  icon: Icons.check_circle_rounded,
                  title: 'Cero Conexiones Bancarias Externas',
                  description:
                      'Sin acceso IMAP a correos ni lectura de notificaciones. Solo existen los ingresos y egresos que tú agregas.',
                ),
                const SizedBox(height: 14),
                const _SecurityBulletRow(
                  icon: Icons.shield_rounded,
                  title: 'Defensa Anti-Prompt Injection y Sandbox XML',
                  description:
                      'Saneamiento de etiquetas XML, detección previa de patrones de jailbreak, temperatura 0.0 y esquema JSON estricto.',
                ),
                const SizedBox(height: 14),
                const _SecurityBulletRow(
                  icon: Icons.lock_rounded,
                  title: 'Protección de Transmisión y Cuota',
                  description:
                      'Cabeceras HTTP sin caché, esquema OpenAPI oculto, límite de tamaño de audio (5 MB) y Rate Limiting activo.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardIconBadge extends StatelessWidget {
  final IconData icon;

  const _CardIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: HermesAccentColors.primaryBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HermesAccentColors.primaryBlue.withValues(alpha: 0.32),
        ),
      ),
      child: Icon(icon, size: 21, color: HermesAccentColors.primaryBlue),
    );
  }
}

class _PercentMiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _PercentMiniField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (_) => onChanged(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            suffixText: '%',
            suffixStyle: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: HermesAccentColors.primaryBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetPreviewBox extends StatelessWidget {
  final String label;
  final String amount;
  final bool highlighted;

  const _BudgetPreviewBox({
    required this.label,
    required this.amount,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted
            ? HermesAccentColors.primaryBlue.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted
              ? HermesAccentColors.primaryBlue.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.25,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              color: highlighted
                  ? HermesAccentColors.primaryBlue
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: highlighted
                    ? HermesAccentColors.primaryBlue
                    : colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBulletRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityBulletRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HermesAccentColors.primaryBlue.withValues(alpha: 0.15),
            border: Border.all(
              color: HermesAccentColors.primaryBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, size: 15, color: HermesAccentColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
