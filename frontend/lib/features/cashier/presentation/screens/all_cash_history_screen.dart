import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/cash_provider.dart';
import '../../providers/all_cash_history_provider.dart';
import '../../data/models/module_model.dart';
import 'widgets/cash_reconciliation_detail_dialog.dart';

class AllCashHistoryScreen extends ConsumerWidget {
  const AllCashHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allCashHistoryProvider);
    final cashState = ref.watch(cashProvider);

    double totalFisico = 0;
    double totalDepositado = 0;
    double totalDiferencia = 0;

    for (final r in state.reconciliations) {
      totalFisico += r.totalGeneral;
      totalDepositado += (r.depositAmount ?? 0);
      final finalDiff = r.isDeposited ? (r.depositDifference ?? r.difference) : r.difference;
      totalDiferencia += finalDiff;
    }

    final isDiferenciaFaltante = totalDiferencia < 0;
    final isDiferenciaPerfecta = totalDiferencia == 0;
    final colorDiferencia = isDiferenciaPerfecta ? Colors.green : (isDiferenciaFaltante ? Colors.red : Colors.orange);
    final textoDiferencia = isDiferenciaPerfecta ? 'CUADRE PERFECTO' : (isDiferenciaFaltante ? 'FALTANTE TOTAL' : 'SOBRANTE TOTAL');

    return Scaffold(
      backgroundColor: ChurchColors.background,
      appBar: AppBar(
        title: const Text('Todos los Cuadres'),
        backgroundColor: ChurchColors.white,
        foregroundColor: ChurchColors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Generar PDF',
            onPressed: () async {
              try {
                final outputFile = await ref.read(allCashHistoryProvider.notifier).downloadPdf();
                if (outputFile != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reporte guardado en: $outputFile')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: ChurchColors.white,
              border: Border(
                bottom: BorderSide(color: ChurchColors.lightGrey),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: state.selectedModuleId,
                    decoration: const InputDecoration(
                      labelText: 'Módulo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos los Módulos'),
                      ),
                      ...cashState.modules.map((m) {
                        return DropdownMenuItem<int?>(
                          value: m.id,
                          child: Text(m.name),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      ref.read(allCashHistoryProvider.notifier).setFilter(
                        moduleId: val,
                        clearModuleId: val == null,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        ref.read(allCashHistoryProvider.notifier).setFilter(
                          startDate: picked,
                        );
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Desde',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        "${state.startDate.day.toString().padLeft(2, '0')}/${state.startDate.month.toString().padLeft(2, '0')}/${state.startDate.year}",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        ref.read(allCashHistoryProvider.notifier).setFilter(
                          endDate: picked,
                        );
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hasta',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        "${state.endDate.day.toString().padLeft(2, '0')}/${state.endDate.month.toString().padLeft(2, '0')}/${state.endDate.year}",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)))
                    : state.reconciliations.isEmpty
                        ? const Center(child: Text('No hay cuadres en este rango.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.reconciliations.length,
                            itemBuilder: (context, index) {
                              final history = state.reconciliations[index];
                              
                              final finalDifference = history.isDeposited
                                  ? (history.depositDifference ?? history.difference)
                                  : history.difference;
                              final isFaltante = finalDifference < 0;
                              final isPerfect = finalDifference == 0;

                              final moduleName = cashState.modules
                                  .firstWhere(
                                    (m) => m.id == history.moduleId,
                                    orElse: () => ModuleModel(id: 0, name: 'Desconocido', isActive: false),
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
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    child: Row(
                                      children: [
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
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    history.isDeposited ? Icons.account_balance : Icons.access_time_filled,
                                                    size: 16,
                                                    color: history.isDeposited ? Colors.green : Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    history.isDeposited
                                                        ? 'Depositado: \$${history.depositAmount?.toStringAsFixed(2) ?? "0.00"}'
                                                        : 'Pendiente de Depósito',
                                                    style: TextStyle(
                                                      color: history.isDeposited ? Colors.green : Colors.orange,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('Efectivo Físico', style: TextStyle(fontSize: 12, color: ChurchColors.grey, fontWeight: FontWeight.bold)),
                                              Text('\$${history.totalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: statusColor, width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(statusText, textAlign: TextAlign.center, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                                              const SizedBox(height: 4),
                                              Text('\$${finalDifference.abs().toStringAsFixed(2)}', style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 14)),
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
          ),
          
          // Resumen Final
          if (!state.isLoading && state.reconciliations.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: ChurchColors.white,
                border: Border(
                  top: BorderSide(color: ChurchColors.lightGrey),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Físico', style: TextStyle(color: ChurchColors.grey, fontSize: 12)),
                        Text('\$${totalFisico.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Depositado', style: TextStyle(color: ChurchColors.grey, fontSize: 12)),
                        Text('\$${totalDepositado.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(textoDiferencia, style: TextStyle(color: colorDiferencia, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('\$${totalDiferencia.abs().toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorDiferencia)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
