import 'package:flutter/material.dart';
import '../../../../../../../core/theme/church_colors.dart';
import '../../../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/cash_reconciliation_model.dart';

class GeneralSummaryWidget extends StatelessWidget {
  final CashReconciliationModel reconciliation;

  const GeneralSummaryWidget({super.key, required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    final totalIngresos = reconciliation.transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalGastos = reconciliation.totalExpenses;
    final netoADepositar = totalIngresos - totalGastos;

    // El cuadre compara el físico contado vs los ingresos registrados.
    // Los gastos reducen lo que va al banco, pero NO afectan si el efectivo cuadra.
    final cuadreDifference = reconciliation.totalGeneral > 0
        ? reconciliation.totalGeneral - totalIngresos
        : 0.0;
    final isCuadrePerfecto =
        cuadreDifference == 0.0 && reconciliation.totalGeneral > 0;
    final isFaltante = cuadreDifference < 0;
    final isSobrante = cuadreDifference > 0;

    return Column(
      children: [
        // ── Sección 1: Movimientos ───────────────────────────────────────
        _SectionCard(
          children: [
            _MetricRow(
              icon: Icons.arrow_downward_rounded,
              iconColor: const Color(0xFF2E7D32),
              iconBg: const Color(0xFFE8F5E9),
              label: 'Ingresos Registrados',
              value: 'RD\$${CurrencyFormatter.formatAmount(totalIngresos)}',
              valueColor: const Color(0xFF2E7D32),
            ),
            const _Separator(),
            _MetricRow(
              icon: Icons.arrow_upward_rounded,
              iconColor: const Color(0xFFC62828),
              iconBg: const Color(0xFFFFEBEE),
              label: 'Total Gastos de Caja',
              value: '- RD\$${CurrencyFormatter.formatAmount(totalGastos)}',
              valueColor: const Color(0xFFC62828),
            ),
            const Divider(height: 24, thickness: 1),
            _MetricRow(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: ChurchColors.primary,
              iconBg: const Color(0xFFE3E9FF),
              label: 'Neto a Depositar',
              value: 'RD\$${CurrencyFormatter.formatAmount(netoADepositar)}',
              valueColor: ChurchColors.primary,
              isLarge: true,
              isBold: true,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Sección 2: Conteo Físico + Estado del Cuadre ────────────────
        _SectionCard(
          children: [
            _MetricRow(
              icon: Icons.wallet_rounded,
              iconColor: const Color(0xFF1565C0),
              iconBg: const Color(0xFFE3F2FD),
              label: 'Efectivo Físico Contado',
              value:
                  'RD\$${CurrencyFormatter.formatAmount(reconciliation.totalGeneral)}',
              valueColor: const Color(0xFF1565C0),
              isLarge: true,
              isBold: true,
            ),
            if (reconciliation.totalGeneral > 0) ...[
              const SizedBox(height: 16),
              _CuadreBadge(
                isCuadrePerfecto: isCuadrePerfecto,
                isFaltante: isFaltante,
                isSobrante: isSobrante,
                amount: cuadreDifference.abs(),
              ),
            ],
          ],
        ),

        // ── Sección 3: Depósito Bancario (solo si ya fue depositado) ────
        if (reconciliation.isDeposited) ...[
          const SizedBox(height: 12),
          _SectionCard(
            headerLabel: 'Depósito Bancario',
            headerIcon: Icons.account_balance_rounded,
            headerColor: const Color(0xFF2E7D32),
            children: [
              _MetricRow(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                label: 'Monto Depositado',
                value:
                    'RD\$${CurrencyFormatter.formatAmount(reconciliation.depositAmount ?? 0.0)}',
                valueColor: const Color(0xFF2E7D32),
                isLarge: true,
                isBold: true,
              ),
              const _Separator(),
              Builder(
                builder: (context) {
                  final depDiff = reconciliation.depositDifference ?? 0.0;
                  final depColor = depDiff == 0
                      ? const Color(0xFF2E7D32)
                      : (depDiff < 0
                            ? const Color(0xFFC62828)
                            : Colors.orange.shade800);
                  return _MetricRow(
                    icon: depDiff == 0
                        ? Icons.done_all_rounded
                        : Icons.warning_amber_rounded,
                    iconColor: depColor,
                    iconBg: depDiff == 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    label: 'Diferencia Final (Depósito vs Físico)',
                    value: 'RD\$${CurrencyFormatter.formatAmount(depDiff)}',
                    valueColor: depColor,
                    isBold: true,
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Tarjeta de sección ────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final String? headerLabel;
  final IconData? headerIcon;
  final Color? headerColor;

  const _SectionCard({
    required this.children,
    this.headerLabel,
    this.headerIcon,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: headerColor?.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(headerIcon, size: 16, color: headerColor),
                  const SizedBox(width: 8),
                  Text(
                    headerLabel!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: headerColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ── Fila de métrica ───────────────────────────────────────────────────────────
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;
  final bool isLarge;
  final bool isBold;

  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLarge = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 14 : 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF4A4A4A),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 17 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── Separador ligero ──────────────────────────────────────────────────────────
class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
    );
  }
}

// ── Badge de estado del cuadre ────────────────────────────────────────────────
class _CuadreBadge extends StatelessWidget {
  final bool isCuadrePerfecto;
  final bool isFaltante;
  final bool isSobrante;
  final double amount;

  const _CuadreBadge({
    required this.isCuadrePerfecto,
    required this.isFaltante,
    required this.isSobrante,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final IconData icon;
    final String label;
    final String? subLabel;

    if (isCuadrePerfecto) {
      bg = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_rounded;
      label = 'CUADRE PERFECTO';
      subLabel = null;
    } else if (isFaltante) {
      bg = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
      icon = Icons.remove_circle_rounded;
      label = 'FALTANTE EN CAJA';
      subLabel = 'RD\$${CurrencyFormatter.formatAmount(amount)}';
    } else {
      bg = const Color(0xFFFFF3E0);
      textColor = Colors.orange.shade800;
      icon = Icons.add_circle_rounded;
      label = 'SOBRANTE EN CAJA';
      subLabel = 'RD\$${CurrencyFormatter.formatAmount(amount)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          if (subLabel != null) ...[
            const Spacer(),
            Text(
              subLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
