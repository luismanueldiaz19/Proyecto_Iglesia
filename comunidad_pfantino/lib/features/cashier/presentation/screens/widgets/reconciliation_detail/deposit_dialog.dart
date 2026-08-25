import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/church_colors.dart';
import '../../../../../accounting/providers/accounting_provider.dart';
import '../../../controllers/cash_reconciliation_detail_controller.dart';

class DepositDialog extends ConsumerStatefulWidget {
  final int reconciliationId;
  final double initialAmount;

  const DepositDialog({
    super.key,
    required this.reconciliationId,
    required this.initialAmount,
  });

  @override
  ConsumerState<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends ConsumerState<DepositDialog> {
  late final TextEditingController _amountCtrl;
  int? _selectedAccountId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(2),
    );

    Future.microtask(() {
      if (ref.read(accountingProvider).accounts.isEmpty) {
        ref.read(accountingProvider.notifier).loadAccounts();
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedAccountId == null) return;

    final depositAmount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (depositAmount <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(
            cashReconciliationDetailProvider(widget.reconciliationId).notifier,
          )
          .executeDeposit(_selectedAccountId!, depositAmount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depósito registrado correctamente.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountingState = ref.watch(accountingProvider);
    final bankAccounts = accountingState.accounts
        .where(
          (a) =>
              (a.type == 'Activo' || a.type == 'asset') &&
              a.isTransactional &&
              a.code.startsWith('1102'),
        )
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Depósito Bancario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ChurchColors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Monto a depositar:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: '\$ ',
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cuenta bancaria de destino:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Cuenta de Banco',
                isDense: true,
              ),
              initialValue: _selectedAccountId,
              items: bankAccounts.map((a) {
                return DropdownMenuItem(
                  value: a.id,
                  child: Text('${a.code} - ${a.name}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: ChurchColors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (_selectedAccountId == null || _isSubmitting)
                      ? null
                      : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmar Depósito',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
