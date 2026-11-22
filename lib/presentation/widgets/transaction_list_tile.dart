import 'package:flutter/material.dart';
import 'package:gemini_app/infrastructure/models/finance_models.dart';

/// Fila reutilizable que muestra un movimiento individual (ícono, concepto, fecha y monto)

class TransactionListTile extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback? onDelete;

  const TransactionListTile({
    super.key,
    required this.item,
    this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isExpense = item.type.isExpense;
    final Color amountColor = isExpense
        ? HermesAccentColors.offlineBannerIcon
        : HermesAccentColors.savingsEmerald;
    final String sign = isExpense ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.category.accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.category.accentColor.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              item.category.icon,
              size: 20,
              color: item.category.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.concept,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.category.title} • ${item.paymentMethod} • ${_formatDate(item.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${formatCurrency(item.amount)}',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: amountColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Eliminar movimiento',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
