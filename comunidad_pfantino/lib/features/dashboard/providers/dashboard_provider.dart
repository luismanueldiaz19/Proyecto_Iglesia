import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/providers/auth_provider.dart';
import '../../cashier/data/models/cash_reconciliation_model.dart';
import '../../cashier/providers/cash_provider.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final List<CashReconciliationModel> reconciliations;
  final String selectedQuickFilter;
  final DateTime startDate;
  final DateTime endDate;

  // Resúmenes calculados
  final double totalFisico;
  final double totalDepositado;
  final double totalFaltante;
  final double totalSobrante;
  final double totalGastos;

  final int cuadresDepositados;
  final int cuadresPendientes;
  final int cuadresAbiertos;

  // Datos para gráfico por mes
  final List<Map<String, dynamic>> monthlyChartData;
  // Datos para gráfico por módulo
  final List<Map<String, dynamic>> moduleChartData;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.reconciliations = const [],
    this.selectedQuickFilter = 'Este año',
    required this.startDate,
    required this.endDate,
    this.totalFisico = 0,
    this.totalDepositado = 0,
    this.totalFaltante = 0,
    this.totalSobrante = 0,
    this.totalGastos = 0,
    this.cuadresDepositados = 0,
    this.cuadresPendientes = 0,
    this.cuadresAbiertos = 0,
    this.monthlyChartData = const [],
    this.moduleChartData = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    List<CashReconciliationModel>? reconciliations,
    String? selectedQuickFilter,
    DateTime? startDate,
    DateTime? endDate,
    double? totalFisico,
    double? totalDepositado,
    double? totalFaltante,
    double? totalSobrante,
    double? totalGastos,
    int? cuadresDepositados,
    int? cuadresPendientes,
    int? cuadresAbiertos,
    List<Map<String, dynamic>>? monthlyChartData,
    List<Map<String, dynamic>>? moduleChartData,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      reconciliations: reconciliations ?? this.reconciliations,
      selectedQuickFilter: selectedQuickFilter ?? this.selectedQuickFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalFisico: totalFisico ?? this.totalFisico,
      totalDepositado: totalDepositado ?? this.totalDepositado,
      totalFaltante: totalFaltante ?? this.totalFaltante,
      totalSobrante: totalSobrante ?? this.totalSobrante,
      totalGastos: totalGastos ?? this.totalGastos,
      cuadresDepositados: cuadresDepositados ?? this.cuadresDepositados,
      cuadresPendientes: cuadresPendientes ?? this.cuadresPendientes,
      cuadresAbiertos: cuadresAbiertos ?? this.cuadresAbiertos,
      monthlyChartData: monthlyChartData ?? this.monthlyChartData,
      moduleChartData: moduleChartData ?? this.moduleChartData,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardNotifier(this.ref)
    : super(
        DashboardState(
          startDate: DateTime(DateTime.now().year, 1, 1),
          endDate: DateTime(DateTime.now().year, 12, 31),
        ),
      ) {
    fetchDashboardData();
  }

  Future<String?> _getToken() async {
    return ref.read(authProvider.notifier).getToken();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(cashRepositoryProvider);

      final startDateStr =
          "${state.startDate.year}-${state.startDate.month.toString().padLeft(2, '0')}-${state.startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${state.endDate.year}-${state.endDate.month.toString().padLeft(2, '0')}-${state.endDate.day.toString().padLeft(2, '0')}";

      final results = await repo.getAllReconciliations(
        token,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      _calculateSummaries(results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _calculateSummaries(List<CashReconciliationModel> data) {
    double fisico = 0;
    double depositado = 0;
    double faltante = 0;
    double sobrante = 0;
    double gastos = 0;
    
    int depositadosCount = 0;
    int pendientesCount = 0;
    int abiertosCount = 0;

    // Para el gráfico agrupado por mes
    Map<String, Map<String, dynamic>> monthlyAggregates = {};
    // Para el gráfico agrupado por módulo
    Map<int, Map<String, dynamic>> moduleAggregates = {};

    for (var r in data) {
      fisico += r.totalGeneral;
      depositado += (r.depositAmount ?? 0);
      gastos += r.totalExpenses;

      if (r.status == 'draft') {
        abiertosCount++;
      } else if (r.isDeposited) {
        depositadosCount++;
      } else {
        pendientesCount++;
      }

      final finalDiff = r.isDeposited
          ? (r.depositDifference ?? r.difference)
          : r.difference;

      if (finalDiff < 0) {
        faltante += finalDiff.abs();
      } else {
        sobrante += finalDiff;
      }

      // Agrupación por módulo
      if (!moduleAggregates.containsKey(r.moduleId)) {
        moduleAggregates[r.moduleId] = {
          'moduleId': r.moduleId,
          'totalFisico': 0.0,
          'totalDepositado': 0.0,
        };
      }
      moduleAggregates[r.moduleId]!['totalFisico'] += r.totalGeneral;
      moduleAggregates[r.moduleId]!['totalDepositado'] +=
          (r.depositAmount ?? 0);

      // Agrupación para el gráfico por mes
      if (r.date.isNotEmpty) {
        try {
          // r.date is formatted as dd/MM/yyyy
          final parts = r.date.split('/');
          if (parts.length == 3) {
            final monthKey = "${parts[2]}-${parts[1]}"; // yyyy-MM

            if (!monthlyAggregates.containsKey(monthKey)) {
              monthlyAggregates[monthKey] = {
                'mes': monthKey,
                'totalFisico': 0.0,
                'totalDepositado': 0.0,
                'modulos': <int, double>{},
              };
            }

            monthlyAggregates[monthKey]!['totalFisico'] += r.totalGeneral;
            monthlyAggregates[monthKey]!['totalDepositado'] +=
                (r.depositAmount ?? 0);

            Map<int, double> mods =
                monthlyAggregates[monthKey]!['modulos'] as Map<int, double>;
            mods[r.moduleId] = (mods[r.moduleId] ?? 0.0) + r.totalGeneral;
          }
        } catch (_) {}
      }
    }

    final sortedKeys = monthlyAggregates.keys.toList()..sort();
    final chartData = sortedKeys.map((k) => monthlyAggregates[k]!).toList();
    final modChartData = moduleAggregates.values.toList();

    state = state.copyWith(
      isLoading: false,
      reconciliations: data,
      totalFisico: fisico,
      totalDepositado: depositado,
      totalFaltante: faltante,
      totalSobrante: sobrante,
      totalGastos: gastos,
      cuadresDepositados: depositadosCount,
      cuadresPendientes: pendientesCount,
      cuadresAbiertos: abiertosCount,
      monthlyChartData: chartData,
      moduleChartData: modChartData,
    );
  }

  void setQuickFilter(String filter) {
    final now = DateTime.now();
    DateTime start = now;
    DateTime end = now;

    switch (filter) {
      case 'Hoy':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Ayer':
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));
        end = DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).subtract(const Duration(days: 1));
        break;
      case 'Esta semana':
        final weekDay = now.weekday;
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekDay - 1));
        end = DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).add(Duration(days: 7 - weekDay));
        break;
      case 'Este mes':
        start = DateTime(now.year, now.month, 1);
        final nextMonth = now.month < 12
            ? DateTime(now.year, now.month + 1, 1)
            : DateTime(now.year + 1, 1, 1);
        end = nextMonth.subtract(const Duration(seconds: 1));
        break;
      case 'Mes pasado':
        final lastMonthDate = now.month == 1
            ? DateTime(now.year - 1, 12, 1)
            : DateTime(now.year, now.month - 1, 1);
        start = DateTime(lastMonthDate.year, lastMonthDate.month, 1);
        end = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(seconds: 1));
        break;
      case 'Este año':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case 'Personalizado':
        return;
    }

    state = state.copyWith(
      selectedQuickFilter: filter,
      startDate: start,
      endDate: end,
    );
    fetchDashboardData();
  }

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      selectedQuickFilter: 'Personalizado',
      startDate: start,
      endDate: end,
    );
    fetchDashboardData();
  }

  void setMonth(int month) {
    final now = DateTime.now();
    final start = DateTime(now.year, month, 1);
    final end = month < 12
        ? DateTime(now.year, month + 1, 1).subtract(const Duration(seconds: 1))
        : DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));

    state = state.copyWith(
      selectedQuickFilter: 'Personalizado',
      startDate: start,
      endDate: end,
    );
    fetchDashboardData();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier(ref);
    });
