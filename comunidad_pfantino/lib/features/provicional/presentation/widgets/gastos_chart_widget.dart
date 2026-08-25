import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

class GastosChartWidget extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> chartData;

  const GastosChartWidget({
    super.key,
    required this.isLoading,
    required this.chartData,
  });

  static const List<String> _months = [
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
    return Container(
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
        children: [
          // Title + legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Gastos por Mes (Año Actual)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Monto',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cantidad de Cheques',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : chartData.isEmpty
                ? const Center(child: Text('Sin datos para el gráfico'))
                : Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: false,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.transparent,
                            tooltipPadding: EdgeInsets.zero,
                            tooltipMargin: 4,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final item = _dataForMonth(group.x);
                              if (item == null) return null;
                              final double total = double.parse(
                                item['total'].toString(),
                              );
                              final int checks =
                                  int.tryParse(
                                    item['num_checks']?.toString() ?? '0',
                                  ) ??
                                  0;

                              if (total == 0 && checks == 0) return null;

                              return BarTooltipItem(
                                '\$${_formatYLabel(total)}\n',
                                TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '$checks cheque${checks != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                      fontSize: 9,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        barGroups: _buildBarGroups(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final int idx = value.toInt();
                                if (idx >= 0 && idx < 12) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _months[idx],
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
                              reservedSize: 44,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('');
                                final double original = value * value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    _formatYLabel(original),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
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
                          horizontalInterval: _getMaxBarY() / 4 > 0
                              ? _getMaxBarY() / 4
                              : 1,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        maxY: _getMaxBarY(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _dataForMonth(int monthIndex) {
    for (final item in chartData) {
      if (int.parse(item['mes'].toString()) - 1 == monthIndex) return item;
    }
    return null;
  }

  List<BarChartGroupData> _buildBarGroups() {
    final double maxY = _getMaxBarY();
    return chartData.map((item) {
      final int monthIndex = int.parse(item['mes'].toString()) - 1;
      final double total = double.parse(item['total'].toString());
      final double displayValue = math.sqrt(total);
      // ignore: unused_local_variable
      final int checks =
          int.tryParse(item['num_checks']?.toString() ?? '0') ?? 0;

      return BarChartGroupData(
        x: monthIndex,
        showingTooltipIndicators: [0],
        barRods: [
          BarChartRodData(
            toY: displayValue,
            // Custom tooltip = the check count badge (via BarTouchData above)
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.red.shade600],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey.shade100,
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxBarY() {
    if (chartData.isEmpty) return 10;
    double max = 0;
    for (final item in chartData) {
      final double total = double.parse(item['total'].toString());
      if (total > max) {
        max = total;
      }
    }
    return max == 0 ? 10 : math.sqrt(max) * 1.25;
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
