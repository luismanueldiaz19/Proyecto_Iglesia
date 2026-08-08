import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../../core/storage/local_storage.dart';
import '../data/repositories/accounting_repository.dart';
import '../data/models/accounting_account_model.dart';

// Repositorio
final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountingRepository(LocalStorage(prefs));
});

// Estado de las cuentas
class AccountingState {
  final bool isLoading;
  final List<AccountingAccountModel> accounts;
  final String? error;

  AccountingState({
    this.isLoading = false,
    this.accounts = const [],
    this.error,
  });

  AccountingState copyWith({
    bool? isLoading,
    List<AccountingAccountModel>? accounts,
    String? error,
  }) {
    return AccountingState(
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      error: error,
    );
  }
}

// Notifier
class AccountingNotifier extends StateNotifier<AccountingState> {
  final AccountingRepository _repository;

  AccountingNotifier(this._repository) : super(AccountingState()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final accounts = await _repository.getAccounts();
      state = state.copyWith(isLoading: false, accounts: accounts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createAccount(AccountingAccountModel newAccount) async {
    try {
      final created = await _repository.createAccount(newAccount);
      state = state.copyWith(
        accounts: [...state.accounts, created]
          ..sort((a, b) => a.code.compareTo(b.code)),
      );
      return true; // Éxito
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false; // Falló
    }
  }

  Future<bool> deleteAccount(int id) async {
    try {
      await _repository.deleteAccount(id);
      state = state.copyWith(
        accounts: state.accounts.where((a) => a.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider principal
final accountingProvider =
    StateNotifierProvider<AccountingNotifier, AccountingState>((ref) {
      final repo = ref.watch(accountingRepositoryProvider);
      return AccountingNotifier(repo);
    });
