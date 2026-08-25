import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/cash_provider.dart';
import '../../data/models/module_model.dart';
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
                final finalDifference = history.isDeposited
                    ? (history.depositDifference ?? history.difference)
                    : history.difference;
                final isFaltante = finalDifference < 0;
                final isPerfect = finalDifference == 0;

                final moduleName = state.modules
                    .firstWhere(
                      (m) => m.id == history.moduleId,
                      orElse: () => ModuleModel(
                        id: 0,
                        name: 'Desconocido',
                        isActive: false,
                      ),
                    )
                    .name;

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
                                  '$moduleName (Cierre #${history.id}) - ${history.date}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ChurchColors.primary,
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                // Text(
                                //   'Gastos registrados: \$${history.totalExpenses.toStringAsFixed(2)}',
                                //   style: const TextStyle(
                                //     color: ChurchColors.grey,
                                //   ),
                                // ),
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
                                          ? 'Depositado en Banco: \$${history.depositAmount?.toStringAsFixed(2) ?? "0.00"}'
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
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryChip(
                                      'Cuadre',
                                      history.totalGeneral,
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryChip(
                                      'Gastos',
                                      history.totalExpenses,
                                      Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryChip(
                                      'A Depositar',
                                      history.totalGeneral -
                                          history.totalExpenses,
                                      Colors.blue,
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
                          !history.isDeposited
                              ? Container(
                                  width: 120,
                                  alignment: Alignment.center,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'SIN DEPOSITAR',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  width: 140,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        '\$${finalDifference.abs().toStringAsFixed(2)}',
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

  Widget _buildSummaryChip(String label, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
