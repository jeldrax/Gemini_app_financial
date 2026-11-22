import 'package:flutter/material.dart';

//================ ARCHIVO DE FORMATEO DE DATOS CAMBIANTE====================

/// Acentos emanticos de colores y se aplican por encima de darkMode `AppTheme`.
abstract final class HermesAccentColors {
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueStrong = Color(0xFF2563EB);
  static const Color skyHighlight = Color(0xFF38BDF8);

  static const Color needsBlue = Color(0xFF3B82F6);
  static const Color wantsAmber = Color(0xFFF59E0B);
  static const Color savingsEmerald = Color(0xFF10B981);

  static const Color offlineBannerBg = Color(0xFF450A0A);
  static const Color offlineBannerBorder = Color(0xFFEF4444);
  static const Color offlineBannerText = Color(0xFFFEE2E2);
  static const Color offlineBannerIcon = Color(0xFFF87171);

  static const Color expenseActiveBg = Color(0xFF991B1B);
  static const Color expenseActiveText = Color(0xFFFECACA);
}

/// Convierte un número a texto de dinero con comas y signo de pesos (por ejemplo: `$2,400.00` o `$1,200`).
String formatCurrency(double value, {int decimals = 2}) {
  final bool isNegative = value < 0;
  final String fixed = value.abs().toStringAsFixed(decimals);
  final List<String> parts = fixed.split('.');
  final String intPart = parts[0];
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < intPart.length; i++) {
    final int remaining = intPart.length - i;
    buffer.write(intPart[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  final String formatted = decimals > 0 && parts.length > 1
      ? '${buffer.toString()}.${parts[1]}'
      : buffer.toString();

  return '${isNegative ? '-' : ''}\$$formatted';
}

/// Categorías fijas del presupuesto (Necesidades, Gustos y Ahorro) junto con su ícono, texto y color.
enum BudgetCategory {
  necesidades(
    title: 'Necesidades',
    shortLabel: 'Nec.',
    subtitle: 'Vivienda, servicios y despensa',
    icon: Icons.home_outlined,
    accentColor: HermesAccentColors.needsBlue,
  ),
  gustos(
    title: 'Gustos',
    shortLabel: 'Gustos',
    subtitle: 'Salidas, suscripciones y ocio',
    icon: Icons.local_fire_department_outlined,
    accentColor: HermesAccentColors.wantsAmber,
  ),
  ahorro(
    title: 'Ahorro',
    shortLabel: 'Ahorro',
    subtitle: 'Fondo de emergencia e inversión',
    icon: Icons.savings_outlined,
    accentColor: HermesAccentColors.savingsEmerald,
  );

  final String title;
  final String shortLabel;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const BudgetCategory({
    required this.title,
    required this.shortLabel,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

/// Define si un movimiento saca dinero (`egreso`) o mete dinero (`ingreso`).
enum TransactionType {
  egreso('Egreso (Gasto)'),
  ingreso('Ingreso');

  final String label;
  const TransactionType(this.label);

  bool get isExpense => this == TransactionType.egreso;
}

/// Historial y sus filtrosde Movimientos `TransactionsScreen`.
enum TransactionHistoryFilter {
  todos,
  soloEgresos,
  soloIngresos,
  necesidades,
  gustos,
  ahorro,
}

/// Guarda el presupuesto mensual base (ej. 2400) y los porcentajes configurables (ej. 50/30/20).
/// Está pensado como variable para que después se cargue y guarde directo desde la base de datos.
class BudgetConfig {
  final double monthlyIncome;
  final int needsPercent;
  final int wantsPercent;
  final int savingsPercent;
  final String currencyCode;

  const BudgetConfig({
    this.monthlyIncome = 2400.0,
    this.needsPercent = 50,
    this.wantsPercent = 30,
    this.savingsPercent = 20,
    this.currencyCode = 'MXN',
  });

  int get totalPercent => needsPercent + wantsPercent + savingsPercent;
  bool get isValidPercentSplit => totalPercent == 100;

  String get splitLabel => '$needsPercent / $wantsPercent / $savingsPercent';
  String get compactSplitLabel => '$needsPercent/$wantsPercent/$savingsPercent';

  int percentFor(BudgetCategory category) {
    switch (category) {
      case BudgetCategory.necesidades:
        return needsPercent;
      case BudgetCategory.gustos:
        return wantsPercent;
      case BudgetCategory.ahorro:
        return savingsPercent;
    }
  }

  double limitFor(BudgetCategory category) {
    return monthlyIncome * (percentFor(category) / 100.0);
  }

  BudgetConfig copyWith({
    double? monthlyIncome,
    int? needsPercent,
    int? wantsPercent,
    int? savingsPercent,
    String? currencyCode,
  }) {
    return BudgetConfig(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      needsPercent: needsPercent ?? this.needsPercent,
      wantsPercent: wantsPercent ?? this.wantsPercent,
      savingsPercent: savingsPercent ?? this.savingsPercent,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

/// Cards las 3 categorias `DashboardScreen`.
class CategoryBudgetSummary {
  final BudgetCategory category;
  final int targetPercent;
  final double allocatedAmount;
  final double netSpentAmount;

  const CategoryBudgetSummary({
    required this.category,
    required this.targetPercent,
    required this.allocatedAmount,
    required this.netSpentAmount,
  });

  double get remainingAmount =>
      (allocatedAmount - netSpentAmount).clamp(0.0, double.infinity);

  double get usageRatio => allocatedAmount <= 0
      ? 0.0
      : (netSpentAmount / allocatedAmount).clamp(0.0, 1.0);
}

/// Representa un movimiento individual (gasto o ingreso) listo para recibir registros del backend/BD.
class TransactionItem {
  final String id;
  final double amount;
  final String concept;
  final BudgetCategory category;
  final TransactionType type;
  final String paymentMethod;
  final DateTime createdAt;
  final String sourceLabel;

  const TransactionItem({
    required this.id,
    required this.amount,
    required this.concept,
    required this.category,
    required this.type,
    required this.paymentMethod,
    required this.createdAt,
    this.sourceLabel = 'Manual',
  });
}

/// Resumen completo del Dashboard calculado automáticamente combinando el presupuesto (`BudgetConfig`) con la lista de movimientos (`List<TransactionItem>`).
class DashboardSummary {
  final BudgetConfig config;
  final double totalNetSpent;
  final double totalRemaining;
  final double spentRatio;
  final double freeRatio;
  final List<CategoryBudgetSummary> categories;

  const DashboardSummary({
    required this.config,
    required this.totalNetSpent,
    required this.totalRemaining,
    required this.spentRatio,
    required this.freeRatio,
    required this.categories,
  });
}

/// Estado de la conexión con Tailscale que se muestra en el banner rojo

class ServerConnectionStatus {
  final bool isConnected;
  final bool isChecking;
  final int? latencyMs;
  final String statusMessage;

  const ServerConnectionStatus({
    this.isConnected = false,
    this.isChecking = false,
    this.latencyMs,
    this.statusMessage = 'No hay conexión activa con tu servidor vía Tailscale',
  });

  ServerConnectionStatus copyWith({
    bool? isConnected,
    bool? isChecking,
    int? latencyMs,
    bool clearLatency = false,
    String? statusMessage,
  }) {
    return ServerConnectionStatus(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
      latencyMs: clearLatency ? null : (latencyMs ?? this.latencyMs),
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
