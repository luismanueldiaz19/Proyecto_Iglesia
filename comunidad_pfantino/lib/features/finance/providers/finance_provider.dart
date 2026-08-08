import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../accounting/data/models/accounting_account_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/finance_repository.dart';
import '../data/models/journal_entry_model.dart';
import '../data/models/journal_entry_line_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});

class FinanceState {
  final bool isLoading;
  final String? error;
  final List<JournalEntryModel> journalEntries;
  final List<AccountingAccountModel> accounts;
  final List<JournalEntryLineModel> ledgerLines;
  final AccountingAccountModel? selectedAccount;

  FinanceState({
    this.isLoading = false,
    this.error,
    this.journalEntries = const [],
    this.accounts = const [],
    this.ledgerLines = const [],
    this.selectedAccount,
  });

  FinanceState copyWith({
    bool? isLoading,
    String? error,
    List<JournalEntryModel>? journalEntries,
    List<AccountingAccountModel>? accounts,
    List<JournalEntryLineModel>? ledgerLines,
    AccountingAccountModel? selectedAccount,
    bool clearError = false,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      journalEntries: journalEntries ?? this.journalEntries,
      accounts: accounts ?? this.accounts,
      ledgerLines: ledgerLines ?? this.ledgerLines,
      selectedAccount: selectedAccount ?? this.selectedAccount,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final FinanceRepository _repository;
  final Ref _ref;

  FinanceNotifier(this._repository, this._ref) : super(FinanceState());

  Future<String?> _getToken() async {
    return await _ref.read(authProvider.notifier).getToken();
  }

  Future<void> fetchJournalEntries() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final entries = await _repository.getJournalEntries(token);
      state = state.copyWith(isLoading: false, journalEntries: entries);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAccounts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _getToken();
      final accounts = await _repository.getAccounts(token!);
      state = state.copyWith(isLoading: false, accounts: accounts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectAccountAndFetchLedger(
    AccountingAccountModel account,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedAccount: account,
    );
    try {
      final token = await _getToken();
      final lines = await _repository.getLedger(token!, account.id);
      state = state.copyWith(isLoading: false, ledgerLines: lines);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((
  ref,
) {
  return FinanceNotifier(ref.read(financeRepositoryProvider), ref);
});
