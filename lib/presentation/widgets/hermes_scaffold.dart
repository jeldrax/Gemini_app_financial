import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';
import 'package:gemini_app/presentation/providers/finance/finance_template_provider.dart';
import 'package:go_router/go_router.dart';

/// Pestañas disponibles en la barra inferior
enum HermesNavTab {
  dashboard('/dashboard', 'Dashboard'),
  movements('/transactions', 'Movimientos'),
  security('/settings', 'Seguridad');

  final String route;
  final String label;
  const HermesNavTab(this.route, this.label);
}

/// Contenedor  compartido por Dashboard, Movimientos y Seguridad 
class HermesScaffold extends ConsumerWidget {
  final HermesNavTab activeTab;
  final Widget child;

  const HermesScaffold({
    super.key,
    required this.activeTab,
    required this.child,
  });

  void _navigateToTab(BuildContext context, HermesNavTab target) {
    if (target == activeTab) return;
    context.pushReplacement(target.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetConfig = ref.watch(budgetConfigProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Text(
          'HERMES ${budgetConfig.compactSplitLabel}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _navigateToTab(context, HermesNavTab.security),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeTab == HermesNavTab.security
                      ? HermesAccentColors.primaryBlue.withValues(alpha: 0.2)
                      : HermesAccentColors.primaryBlueStrong,
                  border: Border.all(
                    color: HermesAccentColors.primaryBlue.withValues(
                      alpha: activeTab == HermesNavTab.security ? 0.5 : 0.35,
                    ),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: activeTab == HermesNavTab.security
                      ? HermesAccentColors.primaryBlue
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: activeTab == HermesNavTab.dashboard
                      ? Icons.pie_chart_rounded
                      : Icons.pie_chart_outline_rounded,
                  label: HermesNavTab.dashboard.label,
                  selected: activeTab == HermesNavTab.dashboard,
                  onTap: () => _navigateToTab(context, HermesNavTab.dashboard),
                ),
                _BottomNavItem(
                  icon: activeTab == HermesNavTab.movements
                      ? Icons.receipt_long_rounded
                      : Icons.receipt_long_outlined,
                  label: HermesNavTab.movements.label,
                  selected: activeTab == HermesNavTab.movements,
                  onTap: () => _navigateToTab(context, HermesNavTab.movements),
                ),
                _BottomNavItem(
                  icon: activeTab == HermesNavTab.security
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  label: HermesNavTab.security.label,
                  selected: activeTab == HermesNavTab.security,
                  onTap: () => _navigateToTab(context, HermesNavTab.security),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color foreground = selected
        ? HermesAccentColors.primaryBlue
        : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: foreground),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta reutilizable con bordes redondeados
class HermesCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const HermesCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              borderColor ?? colorScheme.outlineVariant.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
