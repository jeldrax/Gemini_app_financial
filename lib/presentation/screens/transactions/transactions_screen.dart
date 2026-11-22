import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';
import 'package:gemini_app/presentation/providers/finance/finance_template_provider.dart';
import 'package:gemini_app/presentation/widgets/hermes_scaffold.dart';
import 'package:gemini_app/presentation/widgets/transaction_list_tile.dart';

/// Reactive template for the HERMES "Ingresos y Egresos" screen (`Movimientos.png`).
/// Category percentages and filtered history react automatically to Riverpod state.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  static const List<String> _paymentMethods = [
    'Efectivo',
    'Tarjeta de Débito',
    'Tarjeta de Crédito',
    'Transferencia',
  ];

  final _aiTextCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _conceptCtrl = TextEditingController();

  TransactionType _selectedType = TransactionType.egreso;
  BudgetCategory _selectedCategory = BudgetCategory.necesidades;
  String _selectedMethod = _paymentMethods.first;

  @override
  void dispose() {
    _aiTextCtrl.dispose();
    _amountCtrl.dispose();
    _conceptCtrl.dispose();
    super.dispose();
  }

  void _showTemplateNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  String _filterLabel(
    TransactionHistoryFilter filter,
    BudgetConfig config,
  ) {
    switch (filter) {
      case TransactionHistoryFilter.todos:
        return 'Todos';
      case TransactionHistoryFilter.soloEgresos:
        return 'Solo Egresos';
      case TransactionHistoryFilter.soloIngresos:
        return 'Solo Ingresos';
      case TransactionHistoryFilter.necesidades:
        return '${config.needsPercent}% Necesidades';
      case TransactionHistoryFilter.gustos:
        return '${config.wantsPercent}% Gustos';
      case TransactionHistoryFilter.ahorro:
        return '${config.savingsPercent}% Ahorro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetConfig = ref.watch(budgetConfigProvider);
    final activeFilter = ref.watch(transactionFilterProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return HermesScaffold(
      activeTab: HermesNavTab.movements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ingresos y Egresos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Control 100% manual: formulario exacto o dictado rápido con IA.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // 1. Captura Rápida con IA (Voz o Texto Libre)
          HermesCard(
            borderColor: HermesAccentColors.primaryBlue.withValues(alpha: 0.38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: HermesAccentColors.primaryBlue,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showTemplateNotice(
                          'Dictado de voz pendiente de conectar con Gemini.',
                        ),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Captura Rápida con IA (Voz o Texto Libre)',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dicta o escribe en lenguaje natural y Gemini clasificará el monto y la categoría ${budgetConfig.compactSplitLabel}.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _aiTextCtrl,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  decoration: _fieldDecoration(
                    colorScheme: colorScheme,
                    hintText: 'Ej. "Pagué 450 de luz en efectivo"...',
                    prefixIcon: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: HermesAccentColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _showTemplateNotice(
                      'Análisis con Gemini pendiente de conectar al backend.',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: HermesAccentColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: const Text(
                      'Analizar IA',
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

          // 2. Registro Manual Exacto
          HermesCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: HermesAccentColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Registro Manual Exacto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Segmented Egreso / Ingreso toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TypeToggleButton(
                          label: 'Egreso (Gasto)',
                          icon: Icons.arrow_downward_rounded,
                          selected: _selectedType == TransactionType.egreso,
                          activeBackground: HermesAccentColors.expenseActiveBg,
                          activeForeground: HermesAccentColors.expenseActiveText,
                          onTap: () => setState(
                            () => _selectedType = TransactionType.egreso,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _TypeToggleButton(
                          label: 'Ingreso',
                          icon: Icons.arrow_upward_rounded,
                          selected: _selectedType == TransactionType.ingreso,
                          activeBackground: HermesAccentColors.primaryBlue
                              .withValues(alpha: 0.25),
                          activeForeground: HermesAccentColors.primaryBlue,
                          activeBorderColor: HermesAccentColors.primaryBlue,
                          onTap: () => setState(
                            () => _selectedType = TransactionType.ingreso,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Amount input
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: _fieldDecoration(
                    colorScheme: colorScheme,
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 6),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        child: Text(
                          budgetConfig.currencyCode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Concept input
                TextField(
                  controller: _conceptCtrl,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  decoration: _fieldDecoration(
                    colorScheme: colorScheme,
                    hintText: 'Concepto o motivo (ej. Supermercado)',
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category chips (dynamic percentages from BudgetConfig)
                Text(
                  'Categoría ${budgetConfig.compactSplitLabel}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in BudgetCategory.values)
                      _SelectablePillChip(
                        label: '${cat.title} (${budgetConfig.percentFor(cat)}%)',
                        selected: _selectedCategory == cat,
                        selectedIcon: Icons.check_circle_rounded,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment method chips
                Text(
                  'Método',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final method in _paymentMethods)
                      _SelectablePillChip(
                        label: method,
                        selected: _selectedMethod == method,
                        selectedIcon: Icons.payments_rounded,
                        onTap: () => setState(() => _selectedMethod = method),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Save button
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _showTemplateNotice(
                      'Guardado pendiente de conectar con la base de datos.',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: HermesAccentColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                    ),
                    label: const Text(
                      'Guardar Movimiento',
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
          const SizedBox(height: 22),

          // 3. Filtrar Historial & Resultados Dinámicos
          Text(
            'FILTRAR HISTORIAL',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0;
                    i < TransactionHistoryFilter.values.length;
                    i++) ...[
                  _HistoryFilterChip(
                    label: _filterLabel(
                      TransactionHistoryFilter.values[i],
                      budgetConfig,
                    ),
                    selected:
                        activeFilter == TransactionHistoryFilter.values[i],
                    onTap: () => ref
                        .read(transactionFilterProvider.notifier)
                        .setFilter(TransactionHistoryFilter.values[i]),
                  ),
                  if (i < TransactionHistoryFilter.values.length - 1)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredTransactions.isEmpty)
            HermesCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay movimientos registrados que coincidan con el filtro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            HermesCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTransactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) =>
                    TransactionListTile(item: filteredTransactions[index]),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required ColorScheme colorScheme,
    required String hintText,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? suffixIcon,
    BoxConstraints? suffixIconConstraints,
  }) {
    const radius = BorderRadius.all(Radius.circular(12));
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
        fontSize: 14,
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: suffixIcon,
      suffixIconConstraints: suffixIconConstraints,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: HermesAccentColors.primaryBlue,
          width: 1.4,
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeBackground;
  final Color activeForeground;
  final Color? activeBorderColor;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeBackground,
    required this.activeForeground,
    this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color foreground =
        selected ? activeForeground : colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? activeBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: selected && activeBorderColor != null
              ? Border.all(color: activeBorderColor!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectablePillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData selectedIcon;
  final VoidCallback onTap;

  const _SelectablePillChip({
    required this.label,
    required this.selected,
    required this.selectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? HermesAccentColors.primaryBlue.withValues(alpha: 0.2)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? HermesAccentColors.primaryBlue
                : colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                selectedIcon,
                size: 16,
                color: HermesAccentColors.primaryBlue,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF93C5FD)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? HermesAccentColors.primaryBlue
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? HermesAccentColors.primaryBlue
                : colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
