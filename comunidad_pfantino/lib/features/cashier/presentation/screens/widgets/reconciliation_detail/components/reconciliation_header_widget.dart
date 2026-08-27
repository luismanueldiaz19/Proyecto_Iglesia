import 'package:flutter/material.dart';
import '../../../../../../../core/theme/church_colors.dart';
import '../../../../../data/models/cash_reconciliation_model.dart';

class ReconciliationHeaderWidget extends StatelessWidget {
  final CashReconciliationModel reconciliation;
  final double? fallbackTotalGeneral;
  final double? fallbackTotalExpenses;

  const ReconciliationHeaderWidget({
    super.key,
    required this.reconciliation,
    this.fallbackTotalGeneral,
    this.fallbackTotalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final difference = reconciliation.difference;
    final isFaltante = difference < 0;
    final isPerfect = difference == 0;

    final statusColor = isPerfect
        ? Colors.green
        : isFaltante
        ? Colors.red
        : Colors.orange;

    final statusText = isPerfect
        ? 'Cuadre Perfecto'
        : isFaltante
        ? 'Faltante'
        : 'Sobrante';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChurchColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fecha de Cuadre',
                style: TextStyle(
                  color: ChurchColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reconciliation.date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ChurchColors.black,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'A Depositar',
                style: TextStyle(
                  color: ChurchColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final effGral = reconciliation.totalGeneral > 0 
                      ? reconciliation.totalGeneral 
                      : (fallbackTotalGeneral ?? 0.0);
                  final effExp = reconciliation.totalExpenses > 0 
                      ? reconciliation.totalExpenses 
                      : (fallbackTotalExpenses ?? 0.0);
                  
                  return Text(
                    '\$${(effGral - effExp).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  );
                }
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Diferencia',
                style: TextStyle(
                  color: ChurchColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${difference.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
