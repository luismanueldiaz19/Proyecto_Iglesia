import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/church_colors.dart';

class FinanceDashboardScreen extends StatelessWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChurchColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finanzas y Contabilidad',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ChurchColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestión del libro mayor, diario general y reportes financieros',
              style: TextStyle(fontSize: 16, color: ChurchColors.grey),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.5,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Diario General',
                    description: 'Consulta todos los asientos contables registrados de forma cronológica.',
                    icon: Icons.book_rounded,
                    color: Colors.blue,
                    onTap: () => context.push('/finance/journal'),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Libro Mayor',
                    description: 'Revisa los movimientos y balances específicos de cada cuenta contable.',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.green,
                    onTap: () => context.push('/finance/ledger'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ChurchColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ChurchColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChurchColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: ChurchColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
