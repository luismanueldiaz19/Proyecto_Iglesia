import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/church_colors.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../providers/cash_provider.dart';
import '../../controllers/cash_reconciliation_detail_controller.dart';
import 'reconciliation_detail/deposit_dialog.dart';
import 'reconciliation_detail/add_transaction_dialog.dart';
import 'reconciliation_detail/components/reconciliation_header_widget.dart';
import 'reconciliation_detail/components/transactions_list_widget.dart';
import 'reconciliation_detail/components/denominations_list_widget.dart';
import 'reconciliation_detail/components/general_summary_widget.dart';

class CashReconciliationDetailDialog extends ConsumerWidget {
  final int reconciliationId;

  const CashReconciliationDetailDialog({
    super.key,
    required this.reconciliationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashReconciliationDetailProvider(reconciliationId));
    final controller = ref.read(
      cashReconciliationDetailProvider(reconciliationId).notifier,
    );

    final isAdmin =
        ref.watch(authProvider.notifier).currentUser?.role == 'Administrador';
    final cashNotifier = ref.read(cashProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalle de Cuadre #$reconciliationId',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: ChurchColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ChurchColors.grey),
                    splashRadius: 24,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (reconciliation) {
                  if (reconciliation == null) {
                    return const Center(
                      child: Text('No se encontraron detalles'),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReconciliationHeaderWidget(
                          reconciliation: reconciliation,
                        ),
                        const SizedBox(height: 32),
                        const _SectionTitle(title: 'Transacciones'),
                        const SizedBox(height: 16),
                        TransactionsListWidget(
                          reconciliation: reconciliation,
                          isAdmin: isAdmin,
                          onEditTransaction: (tx) {
                            showDialog(
                              context: context,
                              builder: (_) => AddTransactionDialog(
                                reconciliationId: reconciliationId,
                                transactionToEdit: tx,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        const _SectionTitle(
                          title: 'Desglose Físico (Billetes y Monedas)',
                        ),
                        const SizedBox(height: 16),
                        DenominationsListWidget(reconciliation: reconciliation),
                        const SizedBox(height: 32),
                        const _SectionTitle(title: 'Resumen General'),
                        const SizedBox(height: 16),
                        GeneralSummaryWidget(reconciliation: reconciliation),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: state.maybeWhen(
                data: (reconciliation) {
                  if (reconciliation == null) return const SizedBox.shrink();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!reconciliation.isDeposited &&
                          reconciliation.totalGeneral > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.account_balance, size: 20),
                          label: const Text(
                            'Registrar Depósito Bancario',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => DepositDialog(
                                reconciliationId: reconciliationId,
                                initialAmount:
                                    reconciliation.totalGeneral -
                                    reconciliation.totalExpenses,
                              ),
                            );
                          },
                        ),
                      if (isAdmin) ...[
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: ChurchColors.primary),
                          ),
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                            color: ChurchColors.primary,
                          ),
                          label: const Text(
                            'Añadir Gasto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ChurchColors.primary,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddTransactionDialog(
                                reconciliationId: reconciliationId,
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ChurchColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, size: 20),
                        label: const Text(
                          'Generar PDF',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          try {
                            await controller.openPdf();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al generar PDF: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ChurchColors.black,
        letterSpacing: -0.3,
      ),
    );
  }
}
