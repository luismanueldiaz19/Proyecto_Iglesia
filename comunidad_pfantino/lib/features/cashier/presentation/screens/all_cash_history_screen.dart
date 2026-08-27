import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/presentation/widgets/page_header.dart';
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
      final finalDiff = r.isDeposited
          ? (r.depositDifference ?? r.difference)
          : r.difference;
      totalDiferencia += finalDiff;
    }

    final isDiferenciaFaltante = totalDiferencia < 0;
    final isDiferenciaPerfecta = totalDiferencia == 0;
    final colorDiferencia = isDiferenciaPerfecta
        ? Colors.green
        : (isDiferenciaFaltante ? Colors.red : Colors.orange);
    final textoDiferencia = isDiferenciaPerfecta
        ? 'CUADRE PERFECTO'
        : (isDiferenciaFaltante ? 'FALTANTE TOTAL' : 'SOBRANTE TOTAL');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            PageHeader(
              title: 'Todos los Cuadres',
              subtitle: 'Historial completo de cuadres de caja',
              actionButton: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: ChurchColors.primary,
                    ),
                    tooltip: 'Refrescar',
                    onPressed: () {
                      ref
                          .read(allCashHistoryProvider.notifier)
                          .fetchReconciliations();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    tooltip: 'Generar PDF',
                    onPressed: () async {
                      try {
                        await ref
                            .read(allCashHistoryProvider.notifier)
                            .downloadPdf();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al generar PDF: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Filtros
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ChurchColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChurchColors.lightGrey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: state.selectedModuleId,
                      decoration: const InputDecoration(
                        labelText: 'Módulo',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                        ref
                            .read(allCashHistoryProvider.notifier)
                            .setFilter(
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
                          ref
                              .read(allCashHistoryProvider.notifier)
                              .setFilter(startDate: picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Desde',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                          ref
                              .read(allCashHistoryProvider.notifier)
                              .setFilter(endDate: picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hasta',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                  ? Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.15),
                                offset: const Offset(4, 6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        CashReconciliationDetailDialog(
                                      reconciliationId: history.id,
                                      fallbackTotalGeneral: history.totalGeneral,
                                      fallbackTotalExpenses: history.totalExpenses,
                                    ),
                                  );
                                },
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Franja lateral 3D
                                      Container(width: 6, color: statusColor),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$moduleName (Cierre #${history.id}) - ${history.date}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: ChurchColors
                                                            .primary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          history.isDeposited
                                                              ? Icons
                                                                    .account_balance
                                                              : Icons
                                                                    .access_time_filled,
                                                          size: 16,
                                                          color:
                                                              history
                                                                  .isDeposited
                                                              ? Colors.green
                                                              : Colors.orange,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          history.isDeposited
                                                              ? 'Depositado: \$${history.depositAmount != null ? CurrencyFormatter.formatAmount(history.depositAmount!) : "0.00"}'
                                                              : 'Pendiente de Depósito',
                                                          style: TextStyle(
                                                            color:
                                                                history
                                                                    .isDeposited
                                                                ? Colors.green
                                                                : Colors.orange,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _buildSummaryChip(
                                                          'Gastos',
                                                          history.totalExpenses,
                                                          Colors.red,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _buildSummaryChip(
                                                          'A Depositar',
                                                          history.totalGeneral -
                                                              history
                                                                  .totalExpenses,
                                                          Colors.blue,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    const Text(
                                                      'Efectivo Físico',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            ChurchColors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '\$${CurrencyFormatter.formatAmount(history.totalGeneral)}',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              !history.isDeposited
                                                  ? Container(
                                                      width: 120,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color:
                                                                Colors.orange,
                                                            size: 28,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'SIN DEPOSITAR',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 120,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: statusColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: statusColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            statusText,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '\$${CurrencyFormatter.formatAmount(finalDifference.abs())}',
                                                            style: TextStyle(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                decoration: BoxDecoration(
                  color: ChurchColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ChurchColors.lightGrey),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
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
                          const Text(
                            'Total Físico',
                            style: TextStyle(
                              color: ChurchColors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${CurrencyFormatter.formatAmount(totalFisico)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Depositado',
                            style: TextStyle(
                              color: ChurchColors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${CurrencyFormatter.formatAmount(totalDepositado)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            textoDiferencia,
                            style: TextStyle(
                              color: colorDiferencia,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${CurrencyFormatter.formatAmount(totalDiferencia.abs())}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorDiferencia,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
              '\$${CurrencyFormatter.formatAmount(amount)}',
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
