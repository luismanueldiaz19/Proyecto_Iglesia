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
            style: TextStyle(color: Colors.grey, fontSize: 14),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: '• Depositado: Dinero entregado al banco.\n• En Caja: Efectivo físico pendiente de depósito.\n• Gastos: Salidas de efectivo reportadas en caja.',
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                showDuration: const Duration(seconds: 5),
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: totalParaPorcentaje == 0
                ? const Center(child: Text('Sin datos'))
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 25,
                            sections: [
                              if (depositado > 0)
                                PieChartSectionData(
                                  color: Colors.green.shade500,
                                  value: depositado,
                                  title: '',
                                  radius: 20,
                                ),
                              if (enCaja > 0)
                                PieChartSectionData(
                                  color: Colors.orange.shade500,
                                  value: enCaja,
                                  title: '',
                                  radius: 20,
                                ),
                              if (gastos > 0)
                                PieChartSectionData(
                                  color: Colors.purple.shade500,
                                  value: gastos,
                                  title: '',
                                  radius: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (depositado > 0)
                              _buildLegendItem(
                                Colors.green.shade500,
                                'Depositado',
                                depositado,
                                totalParaPorcentaje,
                              ),
                            if (depositado > 0) const SizedBox(height: 8),
                            if (enCaja > 0)
                              _buildLegendItem(
                                Colors.orange.shade500,
                                'En Caja',
                                enCaja,
                                totalParaPorcentaje,
                              ),
                            if (enCaja > 0) const SizedBox(height: 8),
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
      height: 160, // Más compacto
      padding: const EdgeInsets.all(12.0),
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



  Widget _buildLegendItem(Color color, String text, double value, double total) {
    if (value <= 0) return const SizedBox.shrink();
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
