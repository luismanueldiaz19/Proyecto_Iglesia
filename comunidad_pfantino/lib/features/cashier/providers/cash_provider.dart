import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/repositories/cash_repository.dart';
import '../data/models/module_model.dart';
import '../data/models/denomination_model.dart';
import '../data/models/cash_reconciliation_model.dart';

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  return CashRepository();
});

class CashState {
  final bool isLoading;
  final String? error;
  final List<ModuleModel> modules;
  final List<DenominationModel> denominations;
  final CashReconciliationModel? activeReconciliation;
  final ModuleModel? selectedModule;
  final List<CashReconciliationModel> historyReconciliations;

  CashState({
    this.isLoading = false,
    this.error,
    this.modules = const [],
    this.denominations = const [],
    this.activeReconciliation,
    this.selectedModule,
    this.historyReconciliations = const [],
  });

  CashState copyWith({
    bool? isLoading,
    String? error,
    List<ModuleModel>? modules,
    List<DenominationModel>? denominations,
    CashReconciliationModel? activeReconciliation,
    ModuleModel? selectedModule,
    List<CashReconciliationModel>? historyReconciliations,
    bool clearActiveReconciliation = false,
    bool clearError = false,
  }) {
    return CashState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      modules: modules ?? this.modules,
      denominations: denominations ?? this.denominations,
      activeReconciliation: clearActiveReconciliation
          ? null
          : (activeReconciliation ?? this.activeReconciliation),
      selectedModule: selectedModule ?? this.selectedModule,
      historyReconciliations:
          historyReconciliations ?? this.historyReconciliations,
    );
  }
}

class CashNotifier extends StateNotifier<CashState> {
  final CashRepository _repository;
  final Ref _ref;

  CashNotifier(this._repository, this._ref) : super(CashState()) {
    _init();
  }

  Future<String?> _getToken() async {
    return _ref.read(authProvider.notifier).getToken();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final modules = await _repository.getModules(token);
      final denominations = await _repository.getDenominations(token);

      state = state.copyWith(
        isLoading: false,
        modules: modules,
        denominations: denominations,
        selectedModule: modules.isNotEmpty ? modules.first : null,
      );

      if (modules.isNotEmpty) {
        await checkActiveReconciliation(modules.first.id);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectModule(ModuleModel module) {
    state = state.copyWith(selectedModule: module);
    checkActiveReconciliation(module.id);
  }

  Future<void> checkActiveReconciliation(int moduleId) async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      final reconciliation = await _repository.getCurrentReconciliation(
        token!,
        moduleId,
      );

      if (reconciliation == null) {
        state = state.copyWith(
          isLoading: false,
          clearActiveReconciliation: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          activeReconciliation: reconciliation,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> openReconciliation({DateTime? date}) async {
    if (state.selectedModule == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      String? formattedDate;
      if (date != null) {
        formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      final reconciliation = await _repository.openCashReconciliation(
        token!,
        state.selectedModule!.id,
        date: formattedDate,
      );
      state = state.copyWith(
        isLoading: false,
        activeReconciliation: reconciliation,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> closeReconciliation(
    List<Map<String, dynamic>> denominations,
    double totalGeneral, {
    String? notes,
  }) async {
    if (state.activeReconciliation == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      await _repository.closeCashReconciliation(
        token!,
        state.activeReconciliation!.id,
        denominations,
        totalGeneral,
        notes: notes,
      );

      // Una vez cerrado, limpiamos la caja activa
      state = state.copyWith(isLoading: false, clearActiveReconciliation: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTransaction(
    int accountId,
    double amount,
    String type,
    String description, {
    int? reconciliationId,
  }) async {
    final targetId = reconciliationId ?? state.activeReconciliation?.id;
    if (targetId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      final transaction = await _repository.addTransaction(
        token!,
        targetId,
        accountId,
        amount,
        type,
        description,
      );

      if (reconciliationId == null && state.activeReconciliation != null) {
        final updatedReconciliation = CashReconciliationModel(
          id: state.activeReconciliation!.id,
          moduleId: state.activeReconciliation!.moduleId,
          date: state.activeReconciliation!.date,
          status: state.activeReconciliation!.status,
          totalGeneral: state.activeReconciliation!.totalGeneral,
          totalExpenses: state.activeReconciliation!.totalExpenses,
          difference: state.activeReconciliation!.difference,
          transactions: [
            ...state.activeReconciliation!.transactions,
            transaction,
          ],
        );

        state = state.copyWith(
          isLoading: false,
          activeReconciliation: updatedReconciliation,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateTransaction(
    int transactionId,
    int accountId,
    double amount,
    String type,
    String description,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      await _repository.updateTransaction(
        token!,
        transactionId,
        accountId,
        amount,
        type,
        description,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> fetchHistory() async {
    if (state.selectedModule == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final token = await _getToken();
      final history = await _repository.getReconciliationHistory(
        token!,
        state.selectedModule!.id,
      );
      state = state.copyWith(isLoading: false, historyReconciliations: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> depositCash(
    int reconciliationId,
    int accountId,
    int bankAccountId,
    double amount,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      await _repository.depositReconciliation(
        token,
        reconciliationId,
        accountId,
        bankAccountId,
        amount,
      );

      // Actualizamos el historial
      await fetchHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final cashProvider = StateNotifierProvider<CashNotifier, CashState>((ref) {
  return CashNotifier(ref.read(cashRepositoryProvider), ref);
});
