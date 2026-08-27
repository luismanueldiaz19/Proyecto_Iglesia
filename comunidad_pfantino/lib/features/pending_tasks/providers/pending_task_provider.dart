import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/pending_task_model.dart';
import '../data/repositories/pending_task_repository.dart';

final pendingTaskRepositoryProvider = Provider<PendingTaskRepository>((ref) {
  return PendingTaskRepository();
});

class PendingTaskState {
  final bool isLoading;
  final String? error;
  final List<PendingTaskModel> tasks;
  final PendingTaskModel? selectedTask;
  final String filter; // 'Todos', 'Pendiente', 'Terminado'
  final String searchQuery;
  final int? selectedMonth;
  final int? selectedYear;

  PendingTaskState({
    this.isLoading = false,
    this.error,
    this.tasks = const [],
    this.selectedTask,
    this.filter = 'Todos',
    this.searchQuery = '',
    this.selectedMonth,
    this.selectedYear,
  });

  PendingTaskState copyWith({
    bool? isLoading,
    String? error,
    List<PendingTaskModel>? tasks,
    PendingTaskModel? selectedTask,
    bool clearSelectedTask = false,
    String? filter,
    String? searchQuery,
    int? selectedMonth,
    bool clearMonth = false,
    int? selectedYear,
    bool clearYear = false,
  }) {
    return PendingTaskState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      tasks: tasks ?? this.tasks,
      selectedTask: clearSelectedTask
          ? null
          : (selectedTask ?? this.selectedTask),
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
    );
  }
}

final pendingTaskProvider =
    StateNotifierProvider<PendingTaskNotifier, PendingTaskState>((ref) {
      return PendingTaskNotifier(ref.read(pendingTaskRepositoryProvider), ref);
    });

class PendingTaskNotifier extends StateNotifier<PendingTaskState> {
  final PendingTaskRepository _repository;
  final Ref _ref;

  PendingTaskNotifier(this._repository, this._ref) : super(PendingTaskState()) {
    loadTasks();
  }

  Future<String?> _getToken() async {
    return _ref.read(authProvider.notifier).getToken();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final tasks = await _repository.getPendingTasks(token);
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectTask(PendingTaskModel? task) {
    state = state.copyWith(selectedTask: task, clearSelectedTask: task == null);
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setMonthFilter(int? month, {int? year}) {
    state = state.copyWith(
      selectedMonth: month,
      clearMonth: month == null,
      selectedYear: year ?? state.selectedYear,
    );
  }

  Future<void> createTask(PendingTaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final newTask = await _repository.createPendingTask(token!, task);
      state = state.copyWith(
        isLoading: false,
        tasks: [newTask, ...state.tasks],
        selectedTask: newTask,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateTask(PendingTaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final updatedTask = await _repository.updatePendingTask(
        token!,
        task.id,
        task,
      );

      final index = state.tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final newTasks = [...state.tasks];
        newTasks[index] = updatedTask;
        state = state.copyWith(
          isLoading: false,
          tasks: newTasks,
          selectedTask: updatedTask,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      await _repository.deletePendingTask(token!, id);

      state = state.copyWith(
        isLoading: false,
        tasks: state.tasks.where((t) => t.id != id).toList(),
        clearSelectedTask: state.selectedTask?.id == id,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> downloadPdf() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final url = await _repository.getPdfUrl(
        token!,
        filter: state.filter,
        searchQuery: state.searchQuery,
        month: state.selectedMonth,
        year: state.selectedYear,
      );

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir el PDF');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
