import 'package:flutter/material.dart';
import '../../../../../../../core/theme/church_colors.dart';
import '../../../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/cash_reconciliation_model.dart';
import '../../../../../data/models/cash_transaction_model.dart';

class TransactionsListWidget extends StatelessWidget {
  final CashReconciliationModel reconciliation;
  final bool isAdmin;
  final Function(CashTransactionModel) onEditTransaction;

  const TransactionsListWidget({
    super.key,
    required this.reconciliation,
    required this.isAdmin,
    required this.onEditTransaction,
  });

  @override
  Widget build(BuildContext context) {
    if (reconciliation.transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ChurchColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: Text(
            'No hay transacciones registradas',
            style: TextStyle(
              color: ChurchColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: reconciliation.transactions.map((tx) {
        final isIncome = tx.type == 'income';
        final color = isIncome ? Colors.green : Colors.red;
        final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              tx.description,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Cuenta: ${tx.accountId}',
              style: const TextStyle(fontSize: 12, color: ChurchColors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} RD\$${CurrencyFormatter.formatAmount(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                if (isAdmin && !isIncome) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: ChurchColors.primary,
                    ),
                    onPressed: () => onEditTransaction(tx),
                    splashRadius: 20,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
