import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class TotalWidget extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String tooltipMessage;

  const TotalWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    final themeText = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoración de fondo (icono grande translúcido)
          Positioned(
            right: -5,
            bottom: -5,
            child: Icon(icon, size: 30, color: color.withValues(alpha: 0.15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: themeText.titleSmall?.copyWith(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tooltip(
                      message: tooltipMessage,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      showDuration: const Duration(seconds: 3),
                      triggerMode: TooltipTriggerMode.tap,
                      child: Icon(
                        Icons.help_outline,
                        color: Colors.grey.shade400,
                        size: 12,
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
                    style: themeText.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
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
