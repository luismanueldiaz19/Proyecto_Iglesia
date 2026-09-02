import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/utils/currency_formatter.dart';

class DashboardChartWidget extends StatelessWidget {
  final List<dynamic> chartData;

  const DashboardChartWidget({super.key, required this.chartData});

  static const List<String> _months = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

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
        child: const Center(child: Text('Sin datos para el gráfico')),
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
            color: Colors.blue.withValues(alpha: 0.07),
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
                'Comparativa Mensual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem([
                    Colors.teal.shade400,
                    Colors.green.shade600,
                  ], 'Ingresos'),
                  const SizedBox(width: 16),
                  _buildLegendItem([
                    Colors.orange.shade400,
                    Colors.red.shade600,
                  ], 'Gastos'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4,
                    rotateAngle: -45,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final double originalValue = rod.toY * rod.toY;
                      if (originalValue == 0) return null; // No label for 0

                      return BarTooltipItem(
                        '\$${_formatYLabel(originalValue)}',
                        TextStyle(
                          color: rodIndex == 0
                              ? Colors.teal.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
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
                        final mesStr = dataItem['mes'].toString();
                        final double ingresosMes =
                            double.tryParse(
                              dataItem['ingresos']?.toString() ?? '',
                            ) ??
                            0;
                        final double gastosMes =
                            double.tryParse(
                              dataItem['gastos']?.toString() ?? '',
                            ) ??
                            0;
                        final total = ingresosMes - gastosMes;

                        final parts = mesStr.split('-');
                        final mesNum = int.tryParse(parts.last) ?? 0;
                        final label = mesNum > 0 && mesNum <= 12
                            ? _months[mesNum]
                            : mesStr;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${total >= 0 ? '+' : ''}\$${CurrencyFormatter.formatAmount(total)}',
                                style: TextStyle(
                                  color: total >= 0
                                      ? Colors.blue.shade400
                                      : Colors.redAccent.shade200,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 90,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        final double original = value * value;
                        return SideTitleWidget(
                          // axisSide: meta.axisSide,
                          meta: meta,
                          space: 4,
                          child: Text(
                            _formatYLabel(original),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            softWrap: false,
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
                  final double ingresos =
                      double.tryParse(item['ingresos']?.toString() ?? '') ?? 0;
                  final double gastos =
                      double.tryParse(item['gastos']?.toString() ?? '') ?? 0;

                  return BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: [0, 1],
                    barRods: [
                      BarChartRodData(
                        toY: ingresos > 0 ? math.sqrt(ingresos) : 0,
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.green.shade600],
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
                        toY: gastos > 0 ? math.sqrt(gastos) : 0,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.red.shade600],
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
      final double ingresos =
          double.tryParse(item['ingresos']?.toString() ?? '') ?? 0;
      final double gastos =
          double.tryParse(item['gastos']?.toString() ?? '') ?? 0;
      if (ingresos > max) max = ingresos;
      if (gastos > max) max = gastos;
    }
    return max <= 0 ? 10.0 : math.sqrt(max) * 1.25;
  }

  String _formatYLabel(double value) {
    return CurrencyFormatter.formatAmount(value);
  }
}
