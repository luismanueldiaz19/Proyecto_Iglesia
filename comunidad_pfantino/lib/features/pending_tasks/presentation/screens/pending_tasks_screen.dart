import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/church_colors.dart';
import '../../providers/pending_task_provider.dart';
import '../widgets/task_detail_panel.dart';
import '../widgets/task_list_panel.dart';

class PendingTasksScreen extends ConsumerStatefulWidget {
  const PendingTasksScreen({super.key});

  @override
  ConsumerState<PendingTasksScreen> createState() => _PendingTasksScreenState();
}

class _PendingTasksScreenState extends ConsumerState<PendingTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingTaskProvider);
    final notifier = ref.read(pendingTaskProvider.notifier);

    // Apply filters
    var filteredTasks = state.tasks;
    if (state.filter == 'Pendiente') {
      filteredTasks = filteredTasks
          .where((t) => t.status.toLowerCase() == 'pendiente')
          .toList();
    } else if (state.filter == 'Terminado') {
      filteredTasks = filteredTasks
          .where((t) => t.status.toLowerCase() == 'terminado')
          .toList();
    }

    if (state.selectedMonth != null) {
      filteredTasks = filteredTasks.where((t) {
        return t.planDate.month == state.selectedMonth &&
            (state.selectedYear == null ||
                t.planDate.year == state.selectedYear);
      }).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filteredTasks = filteredTasks.where((t) {
        final planDateStr = t.planDate.toIso8601String().toLowerCase();
        final realDateStr =
            t.completedDate?.toIso8601String().toLowerCase() ?? '';
        return t.title.toLowerCase().contains(q) ||
            t.details.toLowerCase().contains(q) ||
            planDateStr.contains(q) ||
            realDateStr.contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: ChurchColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return _buildMobileLayout(state, notifier, filteredTasks);
          } else {
            return _buildDesktopLayout(state, notifier, filteredTasks);
          }
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return FloatingActionButton(
              backgroundColor: ChurchColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                notifier.selectTask(null);
                _showMobileTaskDialog(context, notifier);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    PendingTaskState state,
    PendingTaskNotifier notifier,
    List<dynamic> filteredTasks,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChurchColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChurchColors.lightGrey),
      ),
      child: TaskListPanel(
        tasks: filteredTasks.cast(),
        allTasks: state.tasks,
        selectedTask: state.selectedTask,
        isLoading: state.isLoading,
        filter: state.filter,
        searchQuery: state.searchQuery,
        selectedMonth: state.selectedMonth,
        isMobile: true,
        onSearch: notifier.setSearchQuery,
        onFilter: notifier.setFilter,
        onMonthFilter: (month) =>
            notifier.setMonthFilter(month == 0 ? null : month),
        onSelect: (task) {
          notifier.selectTask(task);
          _showMobileTaskDialog(context, notifier);
        },
      ),
    );
  }

  void _showMobileTaskDialog(
    BuildContext context,
    PendingTaskNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: ChurchColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(pendingTaskProvider);
                      return TaskDetailPanel(
                        task: state.selectedTask,
                        isMobile: true,
                        onSave: (task) {
                          if (task.id == 0) {
                            notifier.createTask(task);
                          } else {
                            notifier.updateTask(task);
                          }
                          Navigator.pop(ctx);
                        },
                        onDelete: (id) {
                          notifier.deleteTask(id);
                          Navigator.pop(ctx);
                        },
                        onClearSelection: () {
                          notifier.selectTask(null);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    PendingTaskState state,
    PendingTaskNotifier notifier,
    List<dynamic> filteredTasks,
  ) {
    return Row(
      children: [
        // Left Panel: Detail / Form
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChurchColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ChurchColors.lightGrey),
            ),
            child: TaskDetailPanel(
              task: state.selectedTask,
              isMobile: false,
              onSave: (task) {
                if (task.id == 0) {
                  notifier.createTask(task);
                } else {
                  notifier.updateTask(task);
                }
              },
              onDelete: (id) => notifier.deleteTask(id),
              onClearSelection: () => notifier.selectTask(null),
            ),
          ),
        ),

        // Right Panel: List / History
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
            decoration: BoxDecoration(
              color: ChurchColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ChurchColors.lightGrey),
            ),
            child: TaskListPanel(
              tasks: filteredTasks.cast(),
              allTasks: state.tasks,
              selectedTask: state.selectedTask,
              isLoading: state.isLoading,
              filter: state.filter,
              searchQuery: state.searchQuery,
              selectedMonth: state.selectedMonth,
              isMobile: false,
              onSearch: notifier.setSearchQuery,
              onFilter: notifier.setFilter,
              onMonthFilter: (month) =>
                  notifier.setMonthFilter(month == 0 ? null : month),
              onSelect: notifier.selectTask,
            ),
          ),
        ),
      ],
    );
  }
}
