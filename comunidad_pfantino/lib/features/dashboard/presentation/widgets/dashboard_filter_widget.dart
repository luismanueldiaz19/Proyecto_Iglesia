import 'package:flutter/material.dart';

class DashboardFilterWidget extends StatelessWidget {
  final String selectedQuickFilter;
  final Function(String) onQuickFilterChanged;
  final VoidCallback onDateRangeSelected;
  final Function(int) onMonthSelected;
  final VoidCallback refresh;

  const DashboardFilterWidget({
    super.key,
    required this.selectedQuickFilter,
    required this.onQuickFilterChanged,
    required this.onDateRangeSelected,
    required this.onMonthSelected,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: refresh,
          borderRadius: BorderRadius.circular(10),
          child: _buildIconContainer(Icons.refresh, Colors.purple.shade700),
        ),
        const SizedBox(width: 8),
        // Quick filter
        Tooltip(
          message: 'Filtro rápido ($selectedQuickFilter)',
          child: Theme(
            data: Theme.of(context).copyWith(),
            child: PopupMenuButton<String>(
              tooltip: '',
              offset: const Offset(0, 48),
              onSelected: onQuickFilterChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (BuildContext context) =>
                  [
                    'Hoy',
                    'Ayer',
                    'Esta semana',
                    'Este mes',
                    'Mes pasado',
                    'Este año',
                    'Personalizado',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: selectedQuickFilter == value
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedQuickFilter == value
                              ? Colors.teal.shade700
                              : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
              child: _buildIconContainer(
                Icons.filter_alt_outlined,
                Colors.teal.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Date range
        Tooltip(
          message: 'Seleccionar rango de fechas',
          child: InkWell(
            onTap: onDateRangeSelected,
            borderRadius: BorderRadius.circular(10),
            child: _buildIconContainer(
              Icons.date_range_outlined,
              Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Month filter
        Tooltip(
          message: 'Buscar por mes',
          child: Theme(
            data: Theme.of(context).copyWith(),
            child: PopupMenuButton<int>(
              tooltip: '',
              offset: const Offset(0, 48),
              onSelected: onMonthSelected,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(value: 1, child: Text('Enero')),
                const PopupMenuItem<int>(value: 2, child: Text('Febrero')),
                const PopupMenuItem<int>(value: 3, child: Text('Marzo')),
                const PopupMenuItem<int>(value: 4, child: Text('Abril')),
                const PopupMenuItem<int>(value: 5, child: Text('Mayo')),
                const PopupMenuItem<int>(value: 6, child: Text('Junio')),
                const PopupMenuItem<int>(value: 7, child: Text('Julio')),
                const PopupMenuItem<int>(value: 8, child: Text('Agosto')),
                const PopupMenuItem<int>(value: 9, child: Text('Septiembre')),
                const PopupMenuItem<int>(value: 10, child: Text('Octubre')),
                const PopupMenuItem<int>(value: 11, child: Text('Noviembre')),
                const PopupMenuItem<int>(value: 12, child: Text('Diciembre')),
              ],
              child: _buildIconContainer(
                Icons.calendar_month_outlined,
                Colors.blue.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: color, size: 20)),
    );
  }
}
