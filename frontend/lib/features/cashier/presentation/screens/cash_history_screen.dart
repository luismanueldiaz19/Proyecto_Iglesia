import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/cash_provider.dart';
import 'widgets/cash_reconciliation_detail_dialog.dart';

class CashHistoryScreen extends ConsumerStatefulWidget {
  const CashHistoryScreen({super.key});

  @override
  ConsumerState<CashHistoryScreen> createState() => _CashHistoryScreenState();
}

class _CashHistoryScreenState extends ConsumerState<CashHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashProvider.notifier).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashProvider);

    return Scaffold(
      backgroundColor: ChurchColors.background,
      appBar: AppBar(
        title: const Text('Historial de Cuadres'),
        backgroundColor: ChurchColors.white,
        foregroundColor: ChurchColors.black,
        elevation: 0,
      ),
      body: state.isLoading && state.historyReconciliations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            )
          : state.historyReconciliations.isEmpty
          ? const Center(child: Text('No hay historial de cuadres cerrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.historyReconciliations.length,
              itemBuilder: (context, index) {
                final history = state.historyReconciliations[index];
                // final isSobrante = history.difference > 0;
                final isFaltante = history.difference < 0;
                final isPerfect = history.difference == 0;

                Color statusColor;
                if (isPerfect) {
                  statusColor = Colors.green;
                } else if (isFaltante) {
                  statusColor = Colors.red;
                } else {
                  statusColor = Colors.orange;
                }

                String statusText;
                if (isPerfect) {
                  statusText = 'CUADRE PERFECTO';
                } else if (isFaltante) {
                  statusText = 'FALTANTE';
                } else {
                  statusText = 'SOBRANTE';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => CashReconciliationDetailDialog(
                          reconciliationId: history.id,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Info principal
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cierre #${history.id} - ${history.date}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ChurchColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gastos registrados: \$${history.totalExpenses.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: ChurchColors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      history.isDeposited
                                          ? Icons.account_balance
                                          : Icons.access_time_filled,
                                      size: 16,
                                      color: history.isDeposited
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      history.isDeposited
                                          ? 'Depositado en Banco'
                                          : 'Pendiente de Depósito',
                                      style: TextStyle(
                                        color: history.isDeposited
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Totales
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Efectivo Físico',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ChurchColors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${history.totalGeneral.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Diferencia
                          const SizedBox(width: 32),
                          Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  statusText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${history.difference.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
