import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

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
                  : (constraints.maxWidth > 400 ? 2 : 1));

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 116, // Altura fija para evitar el bottom overflow
          ),
          children: [
            _buildCard(
              title: 'Total Físico',
              amount: totalFisico,
              icon: Icons.point_of_sale_outlined,
              color: Colors.blue.shade600,
              tooltipMessage:
                  'Dinero físico total contado en todos los cuadres cerrados de este periodo.',
            ),
            _buildCard(
              title: 'Depositado',
              amount: totalDepositado,
              icon: Icons.account_balance_outlined,
              color: Colors.green.shade600,
              tooltipMessage:
                  'Total de dinero que ya fue marcado como depositado en el banco.',
            ),
            _buildCard(
              title: 'Faltante Total',
              amount: totalFaltante,
              icon: Icons.trending_down,
              color: Colors.red.shade600,
              tooltipMessage:
                  'Suma del dinero faltante registrado al cerrar las cajas.',
            ),
            _buildCard(
              title: 'Sobrante Total',
              amount: totalSobrante,
              icon: Icons.trending_up,
              color: Colors.orange.shade600,
              tooltipMessage:
                  'Suma del dinero sobrante registrado al cerrar las cajas.',
            ),
            _buildCard(
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

  Widget _buildCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required String tooltipMessage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoración de fondo (icono grande translúcido) más pequeña
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 64, // Reducido de 100
              color: color.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0), // Reducido de 20
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Reducido
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 16,
                      ), // Reducido
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12, // Reducido
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tooltip(
                      message: tooltipMessage,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      showDuration: const Duration(seconds: 5),
                      triggerMode: TooltipTriggerMode.tap,
                      child: Icon(
                        Icons.help_outline,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${CurrencyFormatter.formatAmount(amount)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 20, // Reducido de 28
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
