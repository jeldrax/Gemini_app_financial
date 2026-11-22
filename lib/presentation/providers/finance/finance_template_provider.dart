import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';

/// Holds the configurable monthly base budget and percentage split.
/// Later, this notifier will hydrate from and persist to the backend/database.
class BudgetConfigNotifier extends Notifier<BudgetConfig> {
  @override
  BudgetConfig build() => const BudgetConfig();

  void updateConfig({
    double? monthlyIncome,
    int? needsPercent,
    int? wantsPercent,
    int? savingsPercent,
  }) {
    state = state.copyWith(
      monthlyIncome: monthlyIncome,
      needsPercent: needsPercent,
      wantsPercent: wantsPercent,
      savingsPercent: savingsPercent,
    );
  }
}

final budgetConfigProvider =
    NotifierProvider<BudgetConfigNotifier, BudgetConfig>(
      BudgetConfigNotifier.new,
    );

/// Holds the user's transaction list (starts empty in template mode, ready for backend hydration).
class TransactionsNotifier extends Notifier<List<TransactionItem>> {
  @override
  List<TransactionItem> build() => const [];

  void setTransactions(List<TransactionItem> items) {
    state = List<TransactionItem>.unmodifiable(items);
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<TransactionItem>>(
      TransactionsNotifier.new,
    );

/// Active history filter in `TransactionsScreen`.
class TransactionFilterNotifier extends Notifier<TransactionHistoryFilter> {
  @override
  TransactionHistoryFilter build() => TransactionHistoryFilter.todos;

  void setFilter(TransactionHistoryFilter filter) {
    state = filter;
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionHistoryFilter>(
      TransactionFilterNotifier.new,
    );

/// Filtered transaction list derived reactively from `transactionsProvider` + `transactionFilterProvider`.
final filteredTransactionsProvider = Provider<List<TransactionItem>>((ref) {
  final items = ref.watch(transactionsProvider);
  final filter = ref.watch(transactionFilterProvider);

  return items.where((item) {
    switch (filter) {
      case TransactionHistoryFilter.todos:
        return true;
      case TransactionHistoryFilter.soloEgresos:
        return item.type == TransactionType.egreso;
      case TransactionHistoryFilter.soloIngresos:
        return item.type == TransactionType.ingreso;
      case TransactionHistoryFilter.necesidades:
        return item.category == BudgetCategory.necesidades;
      case TransactionHistoryFilter.gustos:
        return item.category == BudgetCategory.gustos;
      case TransactionHistoryFilter.ahorro:
        return item.category == BudgetCategory.ahorro;
    }
  }).toList();
});

/// Derived dashboard summary updated automatically whenever budget config or transactions change.
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final config = ref.watch(budgetConfigProvider);
  final items = ref.watch(transactionsProvider);

  final Map<BudgetCategory, double> netByCategory = {
    BudgetCategory.necesidades: 0.0,
    BudgetCategory.gustos: 0.0,
    BudgetCategory.ahorro: 0.0,
  };

  for (final item in items) {
    final double delta = item.type.isExpense ? item.amount : -item.amount;
    netByCategory[item.category] = (netByCategory[item.category] ?? 0.0) + delta;
  }

  final List<CategoryBudgetSummary> categories = BudgetCategory.values.map((cat) {
    final double net =
        (netByCategory[cat] ?? 0.0).clamp(0.0, double.infinity);
    return CategoryBudgetSummary(
      category: cat,
      targetPercent: config.percentFor(cat),
      allocatedAmount: config.limitFor(cat),
      netSpentAmount: net,
    );
  }).toList();

  final double totalNetSpent = categories.fold(
    0.0,
    (sum, item) => sum + item.netSpentAmount,
  );
  final double totalRemaining =
      (config.monthlyIncome - totalNetSpent).clamp(0.0, double.infinity);
  final double spentRatio = config.monthlyIncome <= 0
      ? 0.0
      : (totalNetSpent / config.monthlyIncome).clamp(0.0, 1.0);
  final double freeRatio = (1.0 - spentRatio).clamp(0.0, 1.0);

  return DashboardSummary(
    config: config,
    totalNetSpent: totalNetSpent,
    totalRemaining: totalRemaining,
    spentRatio: spentRatio,
    freeRatio: freeRatio,
    categories: categories,
  );
});

/// Server/Tailscale connection state for the Dashboard banner and Settings card.
class ConnectionStatusNotifier extends Notifier<ServerConnectionStatus> {
  @override
  ServerConnectionStatus build() => const ServerConnectionStatus();

  void setStatus(ServerConnectionStatus status) {
    state = status;
  }
}

final connectionStatusProvider =
    NotifierProvider<ConnectionStatusNotifier, ServerConnectionStatus>(
      ConnectionStatusNotifier.new,
    );
