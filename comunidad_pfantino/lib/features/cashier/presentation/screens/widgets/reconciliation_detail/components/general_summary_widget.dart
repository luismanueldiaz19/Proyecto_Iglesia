import 'package:flutter/material.dart';
import '../../../../../../../core/theme/church_colors.dart';
import '../../../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/cash_reconciliation_model.dart';

class GeneralSummaryWidget extends StatelessWidget {
  final CashReconciliationModel reconciliation;

  const GeneralSummaryWidget({super.key, required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    final totalIngresos = reconciliation.transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expected = totalIngresos - reconciliation.totalExpenses;
    final difference = reconciliation.difference;
    final isFaltante = difference < 0;
    final isSobrante = difference > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ChurchColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Ingresos Registrados:',
            'RD\$${CurrencyFormatter.formatAmount(totalIngresos)}',
            valueColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total Gastos:',
            'RD\$${CurrencyFormatter.formatAmount(reconciliation.totalExpenses)}',
            valueColor: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'A depositar:',
            'RD\$${CurrencyFormatter.formatAmount(expected)}',
            isBold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildSummaryRow(
            'Efectivo Físico Contado:',
            'RD\$${CurrencyFormatter.formatAmount(reconciliation.totalGeneral)}',
            isBold: true,
            titleBold: true,
            valueColor: Colors.blue,
            valueSize: 18,
          ),
          if (isFaltante || isSobrante) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              isFaltante ? 'Faltante en Caja:' : 'Sobrante en Caja:',
              'RD\$${CurrencyFormatter.formatAmount(difference.abs())}',
              titleBold: true,
              isBold: true,
              valueSize: 16,
              titleColor: isFaltante ? Colors.red : Colors.orange,
              valueColor: isFaltante ? Colors.red : Colors.orange,
            ),
          ],
          if (reconciliation.isDeposited) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _buildSummaryRow(
              'Monto Depositado en Banco:',
              'RD\$${CurrencyFormatter.formatAmount(reconciliation.depositAmount ?? 0.0)}',
              titleBold: true,
              isBold: true,
              valueSize: 18,
              valueColor: Colors.green,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final depDiff = reconciliation.depositDifference ?? 0.0;
                final depColor = depDiff == 0
                    ? Colors.green
                    : (depDiff < 0 ? Colors.red : Colors.orange);
                return _buildSummaryRow(
                  'Diferencia Final (Depósito vs Físico):',
                  'RD\$${CurrencyFormatter.formatAmount(depDiff)}',
                  titleBold: true,
                  isBold: true,
                  valueSize: 18,
                  valueColor: depColor,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
    bool titleBold = false,
    Color? titleColor,
    Color? valueColor,
    double? valueSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: titleBold ? FontWeight.bold : FontWeight.w500,
            color: titleColor ?? ChurchColors.black,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? ChurchColors.black,
            fontSize: valueSize ?? 15,
          ),
        ),
      ],
    );
  }
}
