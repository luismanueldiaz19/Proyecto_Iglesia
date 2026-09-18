import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/total_widget.dart';

class DashboardSummaryCards extends StatelessWidget {
  final double totalFisico;
  final double totalDepositado;
  final double totalFaltante;
  final double totalSobrante;
  final double totalGastos;

  const DashboardSummaryCards({
    super.key,
    required this.totalFisico,
    required this.totalDepositado,
    required this.totalFaltante,
    required this.totalSobrante,
    required this.totalGastos,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En pantallas pequeñas apilamos las tarjetas, en pantallas grandes las mostramos en fila.
        // Hacemos que en tablets (ej. > 800) se muestren las 5 tarjetas.
        final crossAxisCount = constraints.maxWidth > 1000
            ? 5
            : (constraints.maxWidth > 600
                  ? 3
                  : (constraints.maxWidth > 400 ? 2 : 2));

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent: 65, // Reducido drásticamente de 116 a 65
          ),
          children: [
            TotalWidget(
              title: 'Total Físico',
              amount: totalFisico,
              icon: Icons.point_of_sale_outlined,
              color: Colors.blue.shade600,
              tooltipMessage:
                  'Dinero físico total contado en todos los cuadres cerrados de este periodo.',
            ),
            TotalWidget(
              title: 'Depositado',
              amount: totalDepositado,
              icon: Icons.account_balance_outlined,
              color: Colors.green.shade600,
              tooltipMessage:
                  'Total de dinero que ya fue marcado como depositado en el banco.',
            ),
            TotalWidget(
              title: 'Faltante Total',
              amount: totalFaltante,
              icon: Icons.trending_down,
              color: Colors.red.shade600,
              tooltipMessage:
                  'Suma del dinero faltante registrado al cerrar las cajas.',
            ),
            TotalWidget(
              title: 'Sobrante Total',
              amount: totalSobrante,
              icon: Icons.trending_up,
              color: Colors.orange.shade600,
              tooltipMessage:
                  'Suma del dinero sobrante registrado al cerrar las cajas.',
            ),
            TotalWidget(
              title: 'Total Gastos',
              amount: totalGastos,
              icon: Icons.receipt_long_outlined,
              color: Colors.purple.shade600,
              tooltipMessage:
                  'Suma de todos los gastos registrados en los cuadres del periodo.',
            ),
          ],
        );
      },
    );
  }
}
