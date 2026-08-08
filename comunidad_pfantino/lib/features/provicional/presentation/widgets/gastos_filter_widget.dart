import 'package:flutter/material.dart';

class GastosFilterWidget extends StatelessWidget {
  final String selectedQuickFilter;
  final Function(String) onQuickFilterChanged;
  final VoidCallback onDateRangeSelected;
  final Function(int) onMonthSelected;
  final Function(String) onSearchQueryChanged;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onDownloadPdf;
  final VoidCallback onDownloadExcel;
  final VoidCallback onUploadExcel;
  final VoidCallback onShowInfo;
  final bool isUploading;

  const GastosFilterWidget({
    super.key,
    required this.selectedQuickFilter,
    required this.onQuickFilterChanged,
    required this.onDateRangeSelected,
    required this.onMonthSelected,
    required this.onSearchQueryChanged,
    required this.onSearchSubmitted,
    required this.onDownloadPdf,
    required this.onDownloadExcel,
    required this.onUploadExcel,
    required this.onShowInfo,
    required this.isUploading,
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
                    hintText: 'Buscar concepto o número de cheque...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: onSearchQueryChanged,
                  onSubmitted: (_) => onSearchSubmitted(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                tooltip: 'Exportar a PDF',
                onPressed: onDownloadPdf,
              ),
              IconButton(
                icon: Icon(Icons.table_chart, color: Colors.green.shade400),
                tooltip: 'Exportar a Excel',
                onPressed: onDownloadExcel,
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.blue.shade400),
                tooltip: 'Formato Excel para Importar',
                onPressed: onShowInfo,
              ),
              isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.upload_file,
                        color: Colors.orange.shade400,
                      ),
                      tooltip: 'Importar Excel',
                      onPressed: onUploadExcel,
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
                        data: Theme.of(context).copyWith(
                          // Removido cardColor para usar el tema por defecto del popup (blanco)
                        ),
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
