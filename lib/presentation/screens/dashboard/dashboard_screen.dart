import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';
import 'package:gemini_app/presentation/providers/finance/finance_template_provider.dart';
import 'package:gemini_app/presentation/widgets/hermes_scaffold.dart';
import 'package:gemini_app/presentation/widgets/transaction_list_tile.dart';
import 'package:go_router/go_router.dart';

/// Reactive template for the HERMES 50/30/20 Dashboard screen (`Dashboard.png`).
/// All numeric values, percentages, bars and transaction lists read from Riverpod state
/// so backend/database integration only needs to hydrate the providers.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showTemplateNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final connection = ref.watch(connectionStatusProvider);
    final transactions = ref.watch(transactionsProvider);

    return HermesScaffold(
      activeTab: HermesNavTab.dashboard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!connection.isConnected) ...[
            _OfflineStatusBanner(
              message: connection.statusMessage,
              isSyncing: connection.isChecking,
              onSyncPressed: () => _showTemplateNotice(
                context,
                'Sincronización pendiente de conectar con el backend.',
              ),
            ),
            const SizedBox(height: 16),
          ],
          _HeroBalanceCard(
            summary: summary,
            onRegisterPressed: () => context.pushReplacement('/transactions'),
          ),
          const SizedBox(height: 20),
          _SectionLabel(
            'DESGLOSE PRESUPUESTAL ${summary.config.splitLabel}',
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < summary.categories.length; i++) ...[
            _CategoryBreakdownCard(item: summary.categories[i]),
            if (i < summary.categories.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel('ÚLTIMOS MOVIMIENTOS'),
              TextButton.icon(
                onPressed: () => context.pushReplacement('/transactions'),
                style: TextButton.styleFrom(
                  foregroundColor: HermesAccentColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'Registrar / Ver todo',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            _EmptyMovementsCard(
              onAddPressed: () => context.pushReplacement('/transactions'),
            )
          else
            HermesCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) =>
                    TransactionListTile(item: transactions[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfflineStatusBanner extends StatelessWidget {
  final String message;
  final bool isSyncing;
  final VoidCallback onSyncPressed;

  const _OfflineStatusBanner({
    required this.message,
    required this.isSyncing,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: HermesAccentColors.offlineBannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HermesAccentColors.offlineBannerBorder.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: HermesAccentColors.offlineBannerIcon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: HermesAccentColors.offlineBannerText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: isSyncing ? null : onSyncPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.28),
              foregroundColor: HermesAccentColors.offlineBannerText,
              side: BorderSide(
                color: HermesAccentColors.offlineBannerBorder.withValues(
                  alpha: 0.35,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(0, 40),
            ),
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text(
              'Sincronizar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBalanceCard extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback onRegisterPressed;

  const _HeroBalanceCard({
    required this.summary,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = summary.config;
    final int freePercent = (summary.freeRatio * 100).round();

    return HermesCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO RESTANTE DISPONIBLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                formatCurrency(summary.totalRemaining),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.1,
                  color: colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  config.currencyCode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              children: [
                const TextSpan(text: 'Gasto neto acumulado: '),
                TextSpan(
                  text: formatCurrency(summary.totalNetSpent),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text:
                      ' de ${formatCurrency(config.monthlyIncome)} ${config.currencyCode} (${(summary.spentRatio * 100).toStringAsFixed(1)}%)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onRegisterPressed,
              style: FilledButton.styleFrom(
                backgroundColor: HermesAccentColors.primaryBlueStrong,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text(
                'Registrar Ingreso / Egreso',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISTRIBUCIÓN ${config.splitLabel}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$freePercent% libre',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: HermesAccentColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 10,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              child: Row(
                children: [
                  for (int i = 0; i < summary.categories.length; i++) ...[
                    Expanded(
                      flex: summary.categories[i].targetPercent > 0
                          ? summary.categories[i].targetPercent
                          : 1,
                      child: _DistributionBarSegment(
                        category: summary.categories[i],
                      ),
                    ),
                    if (i < summary.categories.length - 1)
                      const SizedBox(width: 2.5),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final cat in summary.categories)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cat.category.accentColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${cat.targetPercent}% ${cat.category.shortLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatCurrency(cat.remainingAmount, decimals: 0),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionBarSegment extends StatelessWidget {
  final CategoryBudgetSummary category;

  const _DistributionBarSegment({required this.category});

  @override
  Widget build(BuildContext context) {
    final Color accent = category.category.accentColor;
    final double remainingFactor = (1.0 - category.usageRatio).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: accent.withValues(alpha: 0.25)),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: remainingFactor,
          child: Container(color: accent),
        ),
      ],
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final CategoryBudgetSummary item;

  const _CategoryBreakdownCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color accent = item.category.accentColor;

    return HermesCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  item.category.icon,
                  size: 21,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Meta ${item.targetPercent}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.usageRatio,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    const TextSpan(text: 'Gasto neto: '),
                    TextSpan(
                      text: formatCurrency(item.netSpentAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Restante: ${formatCurrency(item.remainingAmount)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMovementsCard extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyMovementsCard({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return HermesCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 24,
              color: HermesAccentColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no has registrado ingresos ni egresos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Todos los movimientos son 100% manuales (formulario directo, texto o voz).',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              foregroundColor: HermesAccentColors.primaryBlue,
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Agregar Movimiento',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
