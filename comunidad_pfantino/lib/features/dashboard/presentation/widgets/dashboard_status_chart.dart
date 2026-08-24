import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardStatusChart extends StatelessWidget {
  final int depositados;
  final int pendientes;
  final int abiertos;

  const DashboardStatusChart({
    super.key,
    required this.depositados,
    required this.pendientes,
    required this.abiertos,
  });

  @override
  Widget build(BuildContext context) {
    final total = depositados + pendientes + abiertos;

    if (total == 0) {
      return _buildContainer(
        child: const Center(
          child: Text(
            'No hay cuadres en este periodo',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de los Cuadres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30, // Compacto (anillo)
                      sections: _buildSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(Colors.green.shade500, 'Depositados', depositados, total),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.orange.shade500, 'Pendientes', pendientes, total),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.blue.shade500, 'Abiertos', abiertos, total),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 200, // Compacto
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  List<PieChartSectionData> _buildSections() {
    final List<PieChartSectionData> sections = [];
    final radius = 25.0; // Compacto
    final titleStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    if (depositados > 0) {
      sections.add(PieChartSectionData(
        color: Colors.green.shade500,
        value: depositados.toDouble(),
        title: '$depositados',
        radius: radius,
        titleStyle: titleStyle,
      ));
    }
    if (pendientes > 0) {
      sections.add(PieChartSectionData(
        color: Colors.orange.shade500,
        value: pendientes.toDouble(),
        title: '$pendientes',
        radius: radius,
        titleStyle: titleStyle,
      ));
    }
    if (abiertos > 0) {
      sections.add(PieChartSectionData(
        color: Colors.blue.shade500,
        value: abiertos.toDouble(),
        title: '$abiertos',
        radius: radius,
        titleStyle: titleStyle,
      ));
    }

    return sections;
  }

  Widget _buildLegendItem(Color color, String text, int value, int total) {
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
