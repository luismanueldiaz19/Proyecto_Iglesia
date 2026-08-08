import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../../core/storage/local_storage.dart';
import '../data/repositories/accounting_engine_config_repository.dart';
import '../data/models/accounting_engine_config_model.dart';

final accountingEngineConfigRepositoryProvider = Provider<AccountingEngineConfigRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountingEngineConfigRepository(LocalStorage(prefs));
});

class AccountingEngineConfigState {
  final bool isLoading;
  final List<AccountingEngineConfigModel> configs;
  final String? error;

  AccountingEngineConfigState({
    this.isLoading = false,
    this.configs = const [],
    this.error,
  });

  AccountingEngineConfigState copyWith({
    bool? isLoading,
    List<AccountingEngineConfigModel>? configs,
    String? error,
  }) {
    return AccountingEngineConfigState(
      isLoading: isLoading ?? this.isLoading,
      configs: configs ?? this.configs,
      error: error,
    );
  }
}

class AccountingEngineConfigNotifier extends StateNotifier<AccountingEngineConfigState> {
  final AccountingEngineConfigRepository _repository;

  AccountingEngineConfigNotifier(this._repository) : super(AccountingEngineConfigState()) {
    loadConfigs();
  }

  Future<void> loadConfigs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final configs = await _repository.getConfigs();
      state = state.copyWith(isLoading: false, configs: configs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createConfig(AccountingEngineConfigModel newConfig) async {
    try {
      final created = await _repository.createConfig(newConfig);
      state = state.copyWith(
        configs: [...state.configs, created]
          ..sort((a, b) => a.operationCode.compareTo(b.operationCode)),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteConfig(int id) async {
    try {
      await _repository.deleteConfig(id);
      state = state.copyWith(
        configs: state.configs.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final accountingEngineConfigProvider = StateNotifierProvider<AccountingEngineConfigNotifier, AccountingEngineConfigState>((ref) {
  final repo = ref.watch(accountingEngineConfigRepositoryProvider);
  return AccountingEngineConfigNotifier(repo);
});
