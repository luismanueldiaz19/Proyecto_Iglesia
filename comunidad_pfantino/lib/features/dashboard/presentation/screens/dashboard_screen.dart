import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../cashier/providers/cash_provider.dart';

import '../../providers/dashboard_provider.dart';
import '../widgets/dashboard_filter_widget.dart';
import '../widgets/dashboard_summary_cards.dart';
import '../widgets/dashboard_reconciliation_chart.dart';
import '../widgets/dashboard_module_chart.dart';
import '../widgets/dashboard_status_chart.dart';
import '../widgets/dashboard_distribution_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider.notifier);
    final user = authState.currentUser;

    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);
    final cashState = ref.watch(cashProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido, ${user?.username ?? 'Usuario'}!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: ChurchColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.role ?? 'Desconocido',
                      style: const TextStyle(
                        fontSize: 16,
                        color: ChurchColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   onPressed: () => dashboardNotifier.fetchDashboardData(),
              //   icon: const Icon(Icons.refresh),
              //   tooltip: 'Refrescar datos',
              //   style: IconButton.styleFrom(
              //     backgroundColor: ChurchColors.primary.withOpacity(0.1),
              //     foregroundColor: ChurchColors.primary,
              //     padding: const EdgeInsets.all(12),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 32),

          // Filtross
          DashboardFilterWidget(
            selectedQuickFilter: dashboardState.selectedQuickFilter,
            onQuickFilterChanged: (filter) =>
                dashboardNotifier.setQuickFilter(filter),
            onDateRangeSelected: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: DateTimeRange(
                  start: dashboardState.startDate,
                  end: dashboardState.endDate,
                ),
              );
              if (picked != null) {
                dashboardNotifier.setDateRange(picked.start, picked.end);
              }
            },
            onMonthSelected: (month) => dashboardNotifier.setMonth(month),
            refresh: () => dashboardNotifier.fetchDashboardData(),
          ),

          const SizedBox(height: 24),

          if (dashboardState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (dashboardState.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Error al cargar: ${dashboardState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else ...[
            // Tarjetas de resumen
            DashboardSummaryCards(
              totalFisico: dashboardState.totalFisico,
              totalDepositado: dashboardState.totalDepositado,
              totalFaltante: dashboardState.totalFaltante,
              totalSobrante: dashboardState.totalSobrante,
              totalGastos: dashboardState.totalGastos,
            ),

            const SizedBox(height: 24),

            // Layout de gráficos adaptativo
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Tablet/Desktop: Gráfico principal y Gráfico de estados lado a lado
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            DashboardReconciliationChart(
                              chartData: dashboardState.monthlyChartData,
                            ),
                            const SizedBox(height: 24),
                            DashboardModuleChart(
                              chartData: dashboardState.moduleChartData,
                              modules: cashState.modules,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            DashboardStatusChart(
                              depositados: dashboardState.cuadresDepositados,
                              pendientes: dashboardState.cuadresPendientes,
                              abiertos: dashboardState.cuadresAbiertos,
                            ),
                            const SizedBox(height: 24),
                            DashboardDistributionChart(
                              totalFisico: dashboardState.totalFisico,
                              depositado: dashboardState.totalDepositado,
                              gastos: dashboardState.totalGastos,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile: Todo apilado verticalmente
                  return Column(
                    children: [
                      DashboardReconciliationChart(
                        chartData: dashboardState.monthlyChartData,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardStatusChart(
                              depositados: dashboardState.cuadresDepositados,
                              pendientes: dashboardState.cuadresPendientes,
                              abiertos: dashboardState.cuadresAbiertos,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardDistributionChart(
                              totalFisico: dashboardState.totalFisico,
                              depositado: dashboardState.totalDepositado,
                              gastos: dashboardState.totalGastos,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DashboardModuleChart(
                        chartData: dashboardState.moduleChartData,
                        modules: cashState.modules,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
