import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/cash_reconciliation_model.dart';
import '../../providers/cash_provider.dart';

final cashReconciliationDetailProvider =
    StateNotifierProvider.family<
      CashReconciliationDetailController,
      AsyncValue<CashReconciliationModel?>,
      int
    >((ref, reconciliationId) {
      return CashReconciliationDetailController(ref, reconciliationId);
    });

class CashReconciliationDetailController
    extends StateNotifier<AsyncValue<CashReconciliationModel?>> {
  final Ref _ref;
  final int _reconciliationId;

  CashReconciliationDetailController(this._ref, this._reconciliationId)
    : super(const AsyncValue.loading()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(cashRepositoryProvider);
      final token = _ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final details = await repo.getReconciliationDetails(
        token,
        _reconciliationId,
      );

      state = AsyncValue.data(details);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> executeDeposit(
    int accountId,
    int bankAccountId,
    double amount,
  ) async {
    try {
      await _ref
          .read(cashProvider.notifier)
          .depositCash(_reconciliationId, accountId, bankAccountId, amount);

      // Reload details to reflect the deposit
      await loadDetails();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> openPdf() async {
    try {
      final repo = _ref.read(cashRepositoryProvider);
      final token = _ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final url = await repo.getPdfUrl(token, _reconciliationId);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir el enlace del recibo.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
