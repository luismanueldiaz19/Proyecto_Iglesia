import 'package:flutter/material.dart';

class ExcelFormatInfoDialog {
  static void show(
    BuildContext context, {
    required Map<String, String> expectedColumns,
    VoidCallback? onDownloadTemplate,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Text('Formato del Excel'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El archivo Excel (.xlsx, .csv) debe contener las siguientes columnas obligatorias:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...expectedColumns.entries.map(
                (entry) => _buildInfoRow(entry.key, entry.value),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los nombres de las columnas deben estar en la primera fila (encabezados) exactamente como se indica.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
            if (onDownloadTemplate != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onDownloadTemplate();
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Descargar Plantilla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static Widget _buildInfoRow(String column, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
