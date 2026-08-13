import 'package:flutter/material.dart';
import '../../../../core/theme/church_colors.dart';
import 'package:intl/intl.dart';

class ExcelPreviewDialog extends StatelessWidget {
  final List<dynamic> data;
  final double total;
  final VoidCallback onConfirm;

  const ExcelPreviewDialog({
    super.key,
    required this.data,
    required this.total,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context,
    List<dynamic> data,
    double total,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ExcelPreviewDialog(
        data: data,
        total: total,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vista Previa de Importación',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ChurchColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Se han detectado ${data.length} registros válidos. Por favor verifica que los montos sean correctos antes de importar.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      title: Text(
                        item['concepto'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(item['fecha_ingreso'] ?? ''),
                      trailing: Text(
                        currencyFormatter.format(item['monto'] ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChurchColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Total a Importar: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(total),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ChurchColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChurchColors.primary,
                    foregroundColor: ChurchColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Confirmar e Importar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
