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
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Colors.blueGrey.shade900.withValues(alpha: 0.9),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = chartData[groupIndex];
                      final double ingresos =
                          double.tryParse(item['ingresos'].toString()) ?? 0;
                      final double gastos =
                          double.tryParse(item['gastos'].toString()) ?? 0;
                      final double dif =
                          double.tryParse(item['diferencia'].toString()) ?? 0;

                      String mesStr = item['mes'].toString();
                      int mesNum = int.tryParse(mesStr.split('-').last) ?? 0;
                      String mesNombre = mesNum > 0 && mesNum <= 12
                          ? _months[mesNum]
                          : mesStr;

                      return BarTooltipItem(
                        '$mesNombre\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Ingresos: \$${CurrencyFormatter.formatAmount(ingresos)}\n',
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Gastos: \$${CurrencyFormatter.formatAmount(gastos)}\n',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Dif: ${dif >= 0 ? '+' : ''}\$${CurrencyFormatter.formatAmount(dif)}',
                            style: TextStyle(
                              color: dif >= 0
                                  ? Colors.blue.shade300
                                  : Colors.redAccent.shade100,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                        if (value < 0 || value >= chartData.length)
                          return const SizedBox.shrink();
                        final mesStr = chartData[value.toInt()]['mes']
                            .toString();
                        final parts = mesStr.split('-');
                        final mesNum = int.tryParse(parts.last) ?? 0;
                        final label = mesNum > 0 && mesNum <= 12
                            ? _months[mesNum]
                            : mesStr;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
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
                  final double ingresos =
                      double.tryParse(item['ingresos'].toString()) ?? 0;
                  final double gastos =
                      double.tryParse(item['gastos'].toString()) ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: math.sqrt(ingresos),
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
                        toY: math.sqrt(gastos),
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
      final double ingresos = double.tryParse(item['ingresos'].toString()) ?? 0;
      final double gastos = double.tryParse(item['gastos'].toString()) ?? 0;
      if (ingresos > max) max = ingresos;
      if (gastos > max) max = gastos;
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
