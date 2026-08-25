import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../../../core/theme/church_colors.dart';
import '../../../../../accounting/providers/accounting_provider.dart';
import '../../../../data/models/cash_transaction_model.dart';
import '../../../../providers/cash_provider.dart';
import '../../../controllers/cash_reconciliation_detail_controller.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final int reconciliationId;
  final CashTransactionModel? transactionToEdit;

  const AddTransactionDialog({
    super.key,
    required this.reconciliationId,
    this.transactionToEdit,
  });

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  String _selectedCurrency = 'DOP';
  final String _selectedType = 'expense';
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _rateCtrl.text = '1.0';

    if (widget.transactionToEdit != null) {
      _amountCtrl.text = widget.transactionToEdit!.amount.toStringAsFixed(2);
      _descCtrl.text = widget.transactionToEdit!.description;
      _selectedAccountId = widget.transactionToEdit!.accountId;

      if (widget.transactionToEdit!.description.startsWith('[US\$')) {
        _selectedCurrency = 'USD';
      } else if (widget.transactionToEdit!.description.startsWith('[€')) {
        _selectedCurrency = 'EUR';
      }
    }

    Future.microtask(() {
      if (ref.read(accountingProvider).accounts.isEmpty) {
        ref.read(accountingProvider.notifier).loadAccounts();
      }
    });
  }

  void _onCurrencyChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedCurrency = newValue;
      if (newValue == 'USD') {
        _rateCtrl.text = '58.0';
      } else if (newValue == 'EUR') {
        _rateCtrl.text = '65.0';
      } else {
        _rateCtrl.text = '1.0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref
        .watch(accountingProvider)
        .accounts
        .where((a) => a.isTransactional)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.transactionToEdit == null
                      ? 'Registrar Gasto'
                      : 'Actualizar Gasto',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
            DropdownButtonFormField<int>(
              initialValue: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Cuenta Contable',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: accounts.map((a) {
                return DropdownMenuItem(
                  value: a.id,
                  child: Text('${a.code} - ${a.name}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
            const SizedBox(height: 16),
            CustomDropdownField<String>(
              value: _selectedCurrency,
              labelText: 'Moneda',
              items: const [
                DropdownMenuItem(
                  value: 'DOP',
                  child: Text('Pesos Dominicanos (DOP)'),
                ),
                DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                DropdownMenuItem(value: 'EUR', child: Text('Euros (EUR)')),
              ],
              onChanged: _onCurrencyChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _amountCtrl,
                    labelText: 'Monto Original',
                    prefixText: _selectedCurrency == 'DOP'
                        ? 'RD\$ '
                        : (_selectedCurrency == 'USD' ? 'US\$ ' : '€ '),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                if (_selectedCurrency != 'DOP') ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _rateCtrl,
                      labelText: 'Tasa',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descCtrl,
              labelText: 'Descripción / Concepto',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: ChurchColors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChurchColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectedAccountId == null
                      ? null
                      : () async {
                          final rawAmount =
                              double.tryParse(_amountCtrl.text) ?? 0.0;
                          final rate = double.tryParse(_rateCtrl.text) ?? 1.0;

                          if (rawAmount > 0 && _descCtrl.text.isNotEmpty) {
                            double finalAmount = rawAmount;
                            String finalDesc = _descCtrl.text;

                            if (_selectedCurrency != 'DOP' &&
                                (widget.transactionToEdit == null ||
                                    !widget.transactionToEdit!.description
                                        .startsWith('['))) {
                              finalAmount = rawAmount * rate;
                              final prefix = _selectedCurrency == 'USD'
                                  ? 'US\$'
                                  : '€';
                              finalDesc =
                                  '[$prefix $rawAmount a RD\$$rate] $finalDesc';
                            }

                            final notifier = ref.read(cashProvider.notifier);

                            try {
                              if (widget.transactionToEdit != null) {
                                await notifier.updateTransaction(
                                  widget.transactionToEdit!.id,
                                  _selectedAccountId!,
                                  finalAmount,
                                  _selectedType,
                                  finalDesc,
                                );
                              } else {
                                await notifier.addTransaction(
                                  _selectedAccountId!,
                                  finalAmount,
                                  _selectedType,
                                  finalDesc,
                                  reconciliationId: widget.reconciliationId,
                                );
                              }

                              if (context.mounted) {
                                // Reload details in the detail dialog
                                ref
                                    .read(
                                      cashReconciliationDetailProvider(
                                        widget.reconciliationId,
                                      ).notifier,
                                    )
                                    .loadDetails();
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                  child: Text(
                    widget.transactionToEdit == null
                        ? 'Guardar Gasto'
                        : 'Actualizar',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
