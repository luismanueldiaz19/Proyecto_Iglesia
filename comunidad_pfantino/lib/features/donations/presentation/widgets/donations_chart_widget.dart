import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

class DonationsChartWidget extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> chartData;

  const DonationsChartWidget({
    super.key,
    required this.isLoading,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Donaciones por Mes (Año Actual)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : chartData.isEmpty
                ? const Center(child: Text('Sin datos para el gráfico'))
                : Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: false, // Habilitado para mostrar tooltip
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.white.withOpacity(0.9),
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 4,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              double originalValue = rod.toY * rod.toY;
                              var item = chartData.firstWhere(
                                (e) => (int.parse(e['mes'].toString()) - 1) == group.x.toInt(),
                                orElse: () => {'cantidad': 0}
                              );
                              int cantidad = int.parse(item['cantidad'].toString());
                              return BarTooltipItem(
                                '$cantidad donaciones\n\$${_formatYLabel(originalValue)}',
                                TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        barGroups: chartData.map((item) {
                          int monthIndex =
                              int.parse(item['mes'].toString()) - 1;
                          double total = double.parse(item['total'].toString());
                          double displayValue = math.sqrt(total);
                          return BarChartGroupData(
                            x: monthIndex,
                            showingTooltipIndicators: [0],
                            barRods: [
                              BarChartRodData(
                                toY: displayValue,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal.shade300,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: _getMaxY(chartData),
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const months = [
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
                                if (value.toInt() >= 0 && value.toInt() < 12) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('');
                                double originalValue = value * value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    _formatYLabel(originalValue),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
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
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxY(chartData) / 4 > 0
                              ? _getMaxY(chartData) / 4
                              : 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        maxY: _getMaxY(chartData),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<dynamic> data) {
    if (data.isEmpty) return 10;
    double max = 0;
    for (var item in data) {
      double total = double.parse(item['total'].toString());
      if (total > max) max = total;
    }
    return max == 0 ? 10 : math.sqrt(max) * 1.15;
  }

  String _formatYLabel(double value) {
    if (value >= 999999) {
      String str = (value / 1000000).toStringAsFixed(2);
      if (str.endsWith('.00')) {
        str = str.substring(0, str.length - 3);
      } else if (str.endsWith('0')) {
        str = str.substring(0, str.length - 1);
      }
      return '${str}M';
    } else if (value >= 999) {
      String str = (value / 1000).toStringAsFixed(2);
      if (str.endsWith('.00')) {
        str = str.substring(0, str.length - 3);
      } else if (str.endsWith('0')) {
        str = str.substring(0, str.length - 1);
      }
      return '${str}k';
    }
    return value.toStringAsFixed(0);
  }
}
