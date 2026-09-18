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
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 15, // Compacto (anillo)
                      sections: _buildSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(Colors.green.shade500, 'Depositado', depositados, total),
                      const SizedBox(height: 2),
                      _buildLegendItem(Colors.orange.shade500, 'Pendiente', pendientes, total),
                      const SizedBox(height: 2),
                      _buildLegendItem(Colors.blue.shade500, 'Abierto', abiertos, total),
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
      height: 130, // Más compacto
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  List<PieChartSectionData> _buildSections() {
    final List<PieChartSectionData> sections = [];
    final radius = 15.0; // Compacto
    final titleStyle = const TextStyle(
      fontSize: 9,
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
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9,
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
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
