import 'package:flutter/material.dart';
import '../../../../../../../core/theme/church_colors.dart';
import '../../../../../data/models/cash_reconciliation_model.dart';

class DenominationsListWidget extends StatelessWidget {
  final CashReconciliationModel reconciliation;

  const DenominationsListWidget({super.key, required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    if (reconciliation.denominations.isEmpty) {
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
            'No hay desglose registrado',
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
      children: reconciliation.denominations.map((den) {
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
              backgroundColor: ChurchColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.money,
                color: ChurchColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              '${den.denomination.currency} - ${den.denomination.value.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Cantidad: ${den.quantity}',
              style: const TextStyle(fontSize: 12, color: ChurchColors.grey),
            ),
            trailing: Text(
              '\$${den.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }
}
