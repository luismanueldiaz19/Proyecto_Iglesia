import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/utils/currency_formatter.dart';
import '../../../cashier/data/models/module_model.dart';

class DashboardModuleChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final List<ModuleModel> modules;

  const DashboardModuleChart({
    super.key,
    required this.chartData,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Sin datos por módulo en el rango seleccionado',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Comparativa por Módulo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem([
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ], 'Efectivo Físico'),
                  const SizedBox(width: 16),
                  _buildLegendItem([
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ], 'Depositado'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300, // Altura fija para el gráfico
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey.shade900,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isFisico = rodIndex == 0;
                      final label = isFisico ? 'Físico' : 'Depositado';
                      final value = rod.toY * rod.toY;

                      return BarTooltipItem(
                        '$label\n\$${CurrencyFormatter.formatAmount(value)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= chartData.length) {
                          return const SizedBox.shrink();
                        }

                        final dataItem = chartData[value.toInt()];
                        final moduleId = dataItem['moduleId'] as int;
                        final moduleName = modules
                            .firstWhere(
                              (m) => m.id == moduleId,
                              orElse: () => ModuleModel(
                                id: 0,
                                name: 'Módulo $moduleId',
                                isActive: false,
                              ),
                            )
                            .name;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            moduleName.length > 10
                                ? '${moduleName.substring(0, 8)}...'
                                : moduleName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        final double original = value * value;
                        return Text(
                          _formatYLabel(original),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxBarY() / 4 > 0
                      ? _getMaxBarY() / 4
                      : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                maxY: _getMaxBarY(),
                barGroups: chartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final double fisico = (item['totalFisico'] as num).toDouble();
                  final double depositado = (item['totalDepositado'] as num)
                      .toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: math.sqrt(fisico),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxBarY(),
                          color: Colors.grey.shade100,
                        ),
                      ),
                      BarChartRodData(
                        toY: math.sqrt(depositado),
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxBarY(),
                          color: Colors.grey.shade100,
                        ),
                      ),
                    ],
                    barsSpace: 6,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(List<Color> gradientColors, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  double _getMaxBarY() {
    if (chartData.isEmpty) return 10;
    double max = 0;
    for (final item in chartData) {
      final double fisico = (item['totalFisico'] as num).toDouble();
      final double depositado = (item['totalDepositado'] as num).toDouble();
      if (fisico > max) max = fisico;
      if (depositado > max) max = depositado;
    }
    return max == 0 ? 10 : math.sqrt(max) * 1.25;
  }

  String _formatYLabel(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }
}
