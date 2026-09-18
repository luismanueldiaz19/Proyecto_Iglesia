import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardDistributionChart extends StatelessWidget {
  final double totalFisico;
  final double depositado;
  final double gastos;

  const DashboardDistributionChart({
    super.key,
    required this.totalFisico,
    required this.depositado,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context) {
    if (totalFisico == 0) {
      return _buildContainer(
        child: const Center(
          child: Text(
            'Sin efectivo para mostrar',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // El dinero que no ha sido depositado, sigue en caja
    final enCaja = totalFisico - depositado;
    final totalParaPorcentaje = totalFisico + gastos;

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Destino del Efectivo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: '• Depositado: Dinero entregado al banco.\n• En Caja: Efectivo físico pendiente de depósito.\n• Gastos: Salidas de efectivo reportadas en caja.',
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                showDuration: const Duration(seconds: 3),
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.grey,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: totalParaPorcentaje == 0
                ? const Center(child: Text('Sin datos'))
                : Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 15,
                            sections: [
                              if (depositado > 0)
                                PieChartSectionData(
                                  color: Colors.green.shade500,
                                  value: depositado,
                                  title: '',
                                  radius: 15,
                                ),
                              if (enCaja > 0)
                                PieChartSectionData(
                                  color: Colors.orange.shade500,
                                  value: enCaja,
                                  title: '',
                                  radius: 15,
                                ),
                              if (gastos > 0)
                                PieChartSectionData(
                                  color: Colors.purple.shade500,
                                  value: gastos,
                                  title: '',
                                  radius: 15,
                                ),
                            ],
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
                            if (depositado > 0)
                              _buildLegendItem(
                                Colors.green.shade500,
                                'Depositado',
                                depositado,
                                totalParaPorcentaje,
                              ),
                            if (depositado > 0) const SizedBox(height: 2),
                            if (enCaja > 0)
                              _buildLegendItem(
                                Colors.orange.shade500,
                                'En Caja',
                                enCaja,
                                totalParaPorcentaje,
                              ),
                            if (enCaja > 0) const SizedBox(height: 2),
                            if (gastos > 0)
                              _buildLegendItem(
                                Colors.purple.shade500,
                                'Gastos',
                                gastos,
                                totalParaPorcentaje,
                              ),
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

  Widget _buildLegendItem(Color color, String text, double value, double total) {
    if (value <= 0) return const SizedBox.shrink();
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          '$percentage%',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
