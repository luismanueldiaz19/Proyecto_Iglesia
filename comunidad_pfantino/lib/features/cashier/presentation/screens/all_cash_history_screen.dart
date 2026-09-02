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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Todos los Cuadres',
              subtitle: 'Historial completo de cuadres de caja',
            ),
            const SizedBox(height: 24),
            // Filtros y Acciones
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Lado izquierdo: Filtros
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Módulo
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: state.selectedModuleId,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
                      ),

                      // Rango de fechas
                      InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            initialDateRange: DateTimeRange(
                              start: state.startDate,
                              end: state.endDate,
                            ),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: ChurchColors.primary,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            ref
                                .read(allCashHistoryProvider.notifier)
                                .setFilter(
                                  startDate: picked.start,
                                  endDate: DateTime(
                                    picked.end.year,
                                    picked.end.month,
                                    picked.end.day,
                                    23,
                                    59,
                                    59,
                                  ),
                                );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${state.startDate.day.toString().padLeft(2, '0')}/${state.startDate.month.toString().padLeft(2, '0')}/${state.startDate.year} - ${state.endDate.day.toString().padLeft(2, '0')}/${state.endDate.month.toString().padLeft(2, '0')}/${state.endDate.year}",
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Selector de mes
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: PopupMenuButton<int>(
                          tooltip: 'Buscar por mes (Este año)',
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          position: PopupMenuPosition.under,
                          onSelected: (month) {
                            final now = DateTime.now();
                            if (month == 0) {
                              final startDate = DateTime(now.year, 1, 1);
                              final endDate = DateTime(
                                now.year,
                                12,
                                31,
                                23,
                                59,
                                59,
                              );
                              ref
                                  .read(allCashHistoryProvider.notifier)
                                  .setFilter(
                                    startDate: startDate,
                                    endDate: endDate,
                                  );
                              return;
                            }
                            final startDate = DateTime(now.year, month, 1);
                            final endDate = DateTime(
                              now.year,
                              month + 1,
                              0,
                              23,
                              59,
                              59,
                            );
                            ref
                                .read(allCashHistoryProvider.notifier)
                                .setFilter(
                                  startDate: startDate,
                                  endDate: endDate,
                                );
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Text(
                                'Todo el Año',
                                style: TextStyle(
                                  color: ChurchColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...[
                              'Enero',
                              'Febrero',
                              'Marzo',
                              'Abril',
                              'Mayo',
                              'Junio',
                              'Julio',
                              'Agosto',
                              'Septiembre',
                              'Octubre',
                              'Noviembre',
                              'Diciembre',
                            ].asMap().entries.map((entry) {
                              return PopupMenuItem<int>(
                                value: entry.key + 1,
                                child: Text(
                                  entry.value,
                                  style: TextStyle(color: Colors.grey.shade800),
                                ),
                              );
                            }),
                          ],
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.grey.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Lado derecho: Acciones
                  Wrap(
                    spacing: 8,
                    children: [
                      // Refrescar
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(allCashHistoryProvider.notifier)
                              .fetchReconciliations();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: ChurchColors.primary,
                          size: 18,
                        ),
                        label: Text(
                          'Refrescar',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),

                      // PDF
                      TextButton.icon(
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
                        icon: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red.shade600,
                          size: 18,
                        ),
                        label: Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ],
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
                  : Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.grey.shade50,
                              ),
                              dataRowMaxHeight: 48,
                              dataRowMinHeight: 48,
                              horizontalMargin: 24,
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Cierre #',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Fecha',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Módulo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Efectivo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Gastos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'A Depositar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Depósito',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Diferencia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Acciones',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                              rows: state.reconciliations.map((history) {
                                final finalDifference = history.isDeposited
                                    ? (history.depositDifference ??
                                          history.difference)
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

                                Color statusColor = isPerfect
                                    ? Colors.green
                                    : (isFaltante ? Colors.red : Colors.orange);
                                String statusText = isPerfect
                                    ? 'PERFECTO'
                                    : (isFaltante ? 'FALTANTE' : 'SOBRANTE');

                                final aDepositar =
                                    history.totalGeneral -
                                    history.totalExpenses;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '#${history.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: ChurchColors.primary,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        history.date,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        moduleName,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${CurrencyFormatter.formatAmount(history.totalGeneral)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${CurrencyFormatter.formatAmount(history.totalExpenses)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${CurrencyFormatter.formatAmount(aDepositar)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      history.isDeposited
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '\$${history.depositAmount != null ? CurrencyFormatter.formatAmount(history.depositAmount!) : "0.00"}',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time_filled,
                                                  color: Colors.orange,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Pendiente',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: statusColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isPerfect
                                              ? statusText
                                              : '$statusText (\$${CurrencyFormatter.formatAmount(finalDifference.abs())})',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: ChurchColors.primary,
                                          size: 20,
                                        ),
                                        tooltip: 'Ver Detalle',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                CashReconciliationDetailDialog(
                                                  reconciliationId: history.id,
                                                  fallbackTotalGeneral:
                                                      history.totalGeneral,
                                                  fallbackTotalExpenses:
                                                      history.totalExpenses,
                                                ),
                                          );
                                        },
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
            ),

            // Resumen Final
            if (!state.isLoading && state.reconciliations.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
}
