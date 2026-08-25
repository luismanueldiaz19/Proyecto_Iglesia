import 'package:flutter/material.dart';

class DonationsFilterWidget extends StatelessWidget {
  final String selectedQuickFilter;
  final Function(String) onQuickFilterChanged;
  final VoidCallback onDateRangeSelected;
  final Function(int) onMonthSelected;
  final Function(String)? onSearchQueryChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback onDownloadPdf;
  final VoidCallback? onDownloadExcel;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const DonationsFilterWidget({
    super.key,
    required this.selectedQuickFilter,
    required this.onQuickFilterChanged,
    required this.onDateRangeSelected,
    required this.onMonthSelected,
    this.onSearchQueryChanged,
    this.onSearchSubmitted,
    required this.onDownloadPdf,
    this.onDownloadExcel,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de búsqueda superior
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar donante o concepto...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.teal.shade300,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: onSearchQueryChanged,
                  onSubmitted: (_) => onSearchSubmitted?.call(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onSearchSubmitted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Buscar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Import/Export / PDF
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onDownloadPdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: const Text('PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onDownloadExcel,
                icon: const Icon(Icons.table_chart, color: Colors.green),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Botones inferiores (Filtros y Calendarios)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade300, Colors.teal.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.teal.shade700,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        value: selectedQuickFilter,
                        items:
                            [
                              'Hoy',
                              'Ayer',
                              'Esta semana',
                              'Este mes',
                              'Mes pasado',
                              'Este año',
                              'Personalizado',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            onQuickFilterChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.orange.shade700,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        value: selectedPaymentMethod,
                        items:
                            [
                              'Todos',
                              'Efectivo',
                              'Transferencia',
                              'Cheque',
                              'Tarjeta',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            onPaymentMethodChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.blue.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Tooltip(
                        message: 'Seleccionar rango de fechas',
                        child: InkWell(
                          onTap: onDateRangeSelected,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.date_range,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(),
                        child: PopupMenuButton<int>(
                          icon: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: 'Buscar por mes (Este año)',
                          onSelected: onMonthSelected,
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<int>>[
                                const PopupMenuItem<int>(
                                  value: 1,
                                  child: Text('Enero'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 2,
                                  child: Text('Febrero'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 3,
                                  child: Text('Marzo'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 4,
                                  child: Text('Abril'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 5,
                                  child: Text('Mayo'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 6,
                                  child: Text('Junio'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 7,
                                  child: Text('Julio'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 8,
                                  child: Text('Agosto'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 9,
                                  child: Text('Septiembre'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 10,
                                  child: Text('Octubre'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 11,
                                  child: Text('Noviembre'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 12,
                                  child: Text('Diciembre'),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
