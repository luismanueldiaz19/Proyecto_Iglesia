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
              padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$moduleName (Cierre #${history.id}) - ${history.date}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: ChurchColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          history.isDeposited
                                              ? Icons.account_balance
                                              : Icons.access_time_filled,
                                          size: 14,
                                          color: history.isDeposited
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            history.isDeposited
                                                ? 'Depositado en Banco: \$${history.depositAmount?.toStringAsFixed(2) ?? "0.00"}'
                                                : 'Pendiente de Depósito',
                                            style: TextStyle(
                                              color: history.isDeposited
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Status (SIN DEPOSITAR / FALTANTE)
                              !history.isDeposited
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          Text(
                                            'SIN DEPOSITAR',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: statusColor.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            '\$${finalDifference.abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSummaryChip(
                                    'Cuadre',
                                    history.totalGeneral,
                                    Colors.green,
                                  ),
                                  _buildSummaryChip(
                                    'Gastos',
                                    history.totalExpenses,
                                    Colors.red,
                                  ),
                                  _buildSummaryChip(
                                    'A Depositar',
                                    history.totalGeneral - history.totalExpenses,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Efectivo Físico',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ChurchColors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${history.totalGeneral.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }
}
