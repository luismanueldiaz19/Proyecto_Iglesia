import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/church_colors.dart';
import '../../providers/pending_task_provider.dart';
import '../../data/models/pending_task_model.dart';
import 'task_filter_button.dart';

class TaskListPanel extends StatelessWidget {
  final List<PendingTaskModel> tasks;
  final List<PendingTaskModel> allTasks;
  final PendingTaskModel? selectedTask;
  final bool isLoading;
  final String filter;
  final String searchQuery;
  final int? selectedMonth;
  final Function(String) onSearch;
  final Function(String) onFilter;
  final Function(int) onMonthFilter;
  final Function(PendingTaskModel) onSelect;
  final bool isMobile;

  const TaskListPanel({
    super.key,
    required this.tasks,
    required this.allTasks,
    this.selectedTask,
    required this.isLoading,
    required this.filter,
    required this.searchQuery,
    this.selectedMonth,
    required this.onSearch,
    required this.onFilter,
    required this.onMonthFilter,
    required this.onSelect,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Registros de Auditoría',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSearchBar(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Historial de Registros de Auditoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        return IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          tooltip: 'Descargar PDF',
                          onPressed: () {
                            // Call download method from notifier
                            // Since we don't have direct access here, we could pass it as a callback
                            // OR simply call ref.read(pendingTaskProvider.notifier).downloadPdf() 
                            // Since we are using riverpod, we can do it directly if we import it.
                            ref.read(pendingTaskProvider.notifier).downloadPdf();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    SizedBox(width: 300, child: _buildSearchBar()),
                  ],
                ),
        ),

        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TaskFilterButton(
                  title: 'Todos',
                  count: allTasks.length,
                  isSelected: filter == 'Todos',
                  onTap: () => onFilter('Todos'),
                ),
                const SizedBox(width: 8),
                TaskFilterButton(
                  title: 'Pendiente',
                  count: allTasks
                      .where((t) => t.status.toLowerCase() == 'pendiente')
                      .length,
                  isSelected: filter == 'Pendiente',
                  onTap: () => onFilter('Pendiente'),
                ),
                const SizedBox(width: 8),
                TaskFilterButton(
                  title: 'Terminado',
                  count: allTasks
                      .where((t) => t.status.toLowerCase() == 'terminado')
                      .length,
                  isSelected: filter == 'Terminado',
                  onTap: () => onFilter('Terminado'),
                ),
              ],
            ),
          ),
        ),

        const Divider(height: 32),

        // Table / List
        Expanded(
          child: isLoading && tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
                  ? const Center(child: Text('No hay registros.'))
                  : isMobile
                      ? _buildMobileList()
                      : _buildDesktopTable(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por título o fecha...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ChurchColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ChurchColors.lightGrey),
              ),
            ),
            onChanged: onSearch,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: selectedMonth != null 
                ? ChurchColors.primary.withValues(alpha: 0.1) 
                : Colors.transparent,
            border: Border.all(
              color: selectedMonth != null 
                  ? ChurchColors.primary 
                  : ChurchColors.lightGrey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton<int>(
            tooltip: 'Filtrar por Mes',
            icon: Icon(
              Icons.calendar_month,
              color: selectedMonth != null 
                  ? ChurchColors.primary 
                  : ChurchColors.grey,
            ),
            onSelected: onMonthFilter,
            itemBuilder: (context) {
              final months = [
                'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
              ];
              return <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Todos los meses'),
                ),
                const PopupMenuDivider(),
                ...List.generate(12, (index) {
                  return PopupMenuItem<int>(
                    value: index + 1,
                    child: Text(months[index]),
                  );
                }),
              ];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = selectedTask?.id == task.id;

        return InkWell(
          onTap: () => onSelect(task),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? ChurchColors.primary.withValues(alpha: 0.1)
                  : ChurchColors.white,
              border: Border.all(
                color: isSelected ? ChurchColors.primary : ChurchColors.lightGrey,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${task.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ChurchColors.grey,
                      ),
                    ),
                    _buildStatusBadge(task.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plan: ${DateFormat('yyyy-MM-dd').format(task.planDate)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Real: ${task.completedDate != null ? DateFormat('yyyy-MM-dd').format(task.completedDate!) : '-'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: ChurchColors.lightGrey.withValues(alpha: 0.2),
          child: const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 3,
                child: Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 2,
                child: Text('Fecha Plan.', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 2,
                child: Text('Fecha Real.', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 2,
                child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 2,
                child: Text('Registrado Por', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.separated(
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isSelected = selectedTask?.id == task.id;

              return InkWell(
                onTap: () => onSelect(task),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ChurchColors.primary.withValues(alpha: 0.1)
                        : null,
                    border: isSelected
                        ? Border.all(color: ChurchColors.primary)
                        : Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(task.id.toString()),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(task.planDate),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          task.completedDate != null
                              ? DateFormat('yyyy-MM-dd\nHH:mm')
                                  .format(task.completedDate!)
                              : '-',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(task.status),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          task.registeredByName ??
                              task.registeredByUsername ??
                              'Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isTerminado = status.toLowerCase() == 'terminado';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTerminado
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: isTerminado ? Colors.green[800] : Colors.orange[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
