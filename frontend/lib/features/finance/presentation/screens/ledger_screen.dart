import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../accounting/data/models/accounting_account_model.dart';
import '../../providers/finance_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(financeProvider.notifier).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final notifier = ref.read(financeProvider.notifier);

    double currentBalance = 0.0;

    return Scaffold(
      backgroundColor: ChurchColors.background,
      appBar: AppBar(
        title: const Text(
          'Libro Mayor',
          style: TextStyle(
            color: ChurchColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ChurchColors.white,
        iconTheme: const IconThemeData(color: ChurchColors.black),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: ChurchColors.lightGrey, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: ChurchColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: state.accounts.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : CustomDropdownField<AccountingAccountModel>(
                      value: state.selectedAccount,
                      labelText: 'Seleccionar Cuenta Contable',
                      items: state.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text('${acc.code} - ${acc.name}'),
                        );
                      }).toList(),
                      onChanged: (acc) {
                        if (acc != null) {
                          notifier.selectAccountAndFetchLedger(acc);
                        }
                      },
                    ),
            ),
            const SizedBox(height: 24),
            if (state.isLoading && state.accounts.isNotEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (state.selectedAccount == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Selecciona una cuenta para ver sus movimientos.',
                  ),
                ),
              )
            else if (state.ledgerLines.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay movimientos para esta cuenta.'),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ChurchColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ChurchColors.lightGrey),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChurchColors.grey,
                        ),
                        columns: const [
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Concepto')),
                          DataColumn(label: Text('Débito')),
                          DataColumn(label: Text('Crédito')),
                          DataColumn(label: Text('Balance')),
                        ],
                        rows: state.ledgerLines.map((line) {
                          // Calcular balance: Activos y Gastos aumentan con débito, Pasivos e Ingresos con crédito
                          // Para simplificar, mostramos el acumulado.
                          final type = state.selectedAccount!.type;
                          final isDebitIncrease =
                              type == 'Activo' || type == 'Gasto';

                          if (isDebitIncrease) {
                            currentBalance += line.debit - line.credit;
                          } else {
                            currentBalance += line.credit - line.debit;
                          }

                          return DataRow(
                            cells: [
                              DataCell(Text(line.journalEntry?.date ?? '-')),
                              DataCell(
                                Text(
                                  line.journalEntry?.description ??
                                      'Asiento #${line.journalEntryId}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  line.debit > 0
                                      ? '\$${line.debit.toStringAsFixed(2)}'
                                      : '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                              DataCell(
                                Text(
                                  line.credit > 0
                                      ? '\$${line.credit.toStringAsFixed(2)}'
                                      : '',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$${currentBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
