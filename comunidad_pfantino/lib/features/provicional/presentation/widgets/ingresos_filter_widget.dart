import 'package:flutter/material.dart';

class IngresosFilterWidget extends StatelessWidget {
  final String selectedQuickFilter;
  final Function(String) onQuickFilterChanged;
  final VoidCallback onDateRangeSelected;
  final Function(int) onMonthSelected;
  final Function(String)? onSearchQueryChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback onDownloadPdf;
  final VoidCallback? onDownloadExcel;
  final VoidCallback? onUploadExcel;
  final VoidCallback onShowInfo;
  final bool isUploading;
  final bool showSearchAndExport;

  const IngresosFilterWidget({
    super.key,
    required this.selectedQuickFilter,
    required this.onQuickFilterChanged,
    required this.onDateRangeSelected,
    required this.onMonthSelected,
    this.onSearchQueryChanged,
    this.onSearchSubmitted,
    required this.onDownloadPdf,
    this.onDownloadExcel,
    this.onUploadExcel,
    required this.onShowInfo,
    required this.isUploading,
    this.showSearchAndExport = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // 1. Barra de Búsqueda (Toma el espacio disponible pero maximo 350px)
          if (showSearchAndExport)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar concepto o recibo...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                ),
                onChanged: onSearchQueryChanged,
                onSubmitted: (_) => onSearchSubmitted?.call(),
              ),
            )
          else
            const SizedBox.shrink(),

          // 2. Controles de Filtros y Acciones
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Filtro rápido (Dropdown limpio)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedQuickFilter,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w500),
                    items: [
                      'Hoy', 'Ayer', 'Esta semana', 'Este mes', 'Mes pasado', 'Este año', 'Personalizado'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) onQuickFilterChanged(newValue);
                    },
                  ),
                ),
              ),

              // Rango de fechas
              Tooltip(
                message: 'Rango de fechas',
                child: IconButton(
                  onPressed: onDateRangeSelected,
                  icon: const Icon(Icons.date_range, size: 22),
                  color: Colors.grey.shade700,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              // Selector de mes
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: PopupMenuButton<int>(
                  tooltip: 'Buscar por mes (Este año)',
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  position: PopupMenuPosition.under,
                  onSelected: onMonthSelected,
                  itemBuilder: (BuildContext context) => [
                    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
                  ].asMap().entries.map((entry) {
                    return PopupMenuItem<int>(
                      value: entry.key + 1,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_month, size: 22, color: Colors.grey.shade700),
                  ),
                ),
              ),

              if (showSearchAndExport) ...[
                // Divisor vertical
                Container(width: 1, height: 24, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 4)),

                // Exportar PDF
                TextButton.icon(
                  onPressed: onDownloadPdf,
                  icon: Icon(Icons.picture_as_pdf, color: Colors.red.shade600, size: 18),
                  label: Text('PDF', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),

                // Exportar Excel
                if (onDownloadExcel != null)
                  TextButton.icon(
                    onPressed: onDownloadExcel,
                    icon: Icon(Icons.table_chart, color: Colors.green.shade600, size: 18),
                    label: Text('Excel', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),

                // Importar
                if (onUploadExcel != null)
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : onUploadExcel,
                    icon: isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.upload_file, size: 18),
                    label: Text(isUploading ? 'Subiendo...' : 'Importar', style: const TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
