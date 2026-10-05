import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/loan_model.dart';
import '../data/repositories/loan_repository.dart';

final loanProvider =
    StateNotifierProvider<LoanNotifier, AsyncValue<List<LoanModel>>>((ref) {
      return LoanNotifier(ref);
    });

final loanDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  loanId,
) async {
  final token = ref.read(authProvider.notifier).getToken();
  if (token == null) throw Exception('No autenticado');

  final repo = ref.read(loanRepositoryProvider);
  return await repo.getLoanDetails(loanId, token);
});

class LoanNotifier extends StateNotifier<AsyncValue<List<LoanModel>>> {
  final Ref ref;

  LoanNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadLoans();
  }

  Future<void> loadLoans() async {
    try {
      state = const AsyncValue.loading();
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(loanRepositoryProvider);
      final loans = await repo.getLoans(token);

      state = AsyncValue.data(loans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<LoanModel?> createLoan(LoanModel loan) async {
    try {
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(loanRepositoryProvider);
      final newLoan = await repo.createLoan(loan, token);

      if (state is AsyncData) {
        state = AsyncValue.data([newLoan, ...state.value!]);
      } else {
        await loadLoans();
      }

      return newLoan;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoanModel?> updateLoan(int id, LoanModel loan) async {
    try {
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(loanRepositoryProvider);
      final updatedLoan = await repo.updateLoan(id, loan, token);

      if (state is AsyncData) {
        final currentLoans = state.value!;
        final index = currentLoans.indexWhere((l) => l.id == id);
        if (index != -1) {
          final newLoans = [...currentLoans];
          newLoans[index] = updatedLoan;
          state = AsyncValue.data(newLoans);
        } else {
          await loadLoans();
        }
      } else {
        await loadLoans();
      }

      return updatedLoan;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> applyPayment(
    int loanId,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(loanRepositoryProvider);
      await repo.applyPayment(loanId, paymentData, token);

      // Reload loans to update balances
      await loadLoans();
    } catch (e) {
      rethrow;
    }
  }
}
