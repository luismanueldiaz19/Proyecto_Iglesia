import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/repositories/donation_repository.dart';

final donationProvider =
    StateNotifierProvider<DonationNotifier, AsyncValue<void>>((ref) {
      return DonationNotifier(ref);
    });

class DonationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  DonationNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<int?> createDonation({
    required String donorName,
    String? donorPhone,
    String? donorCedula,
    String? donorRnc,
    required bool withReceipt,
    required String paymentMethod,
    required String concept,
    required double amount,
    DateTime? date,
  }) async {
    try {
      state = const AsyncValue.loading();
      // final token = ref.read(authProvider.notifier).getToken();
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(donationRepositoryProvider);
      final donation = await repo.createDonation(
        donorName: donorName,
        donorPhone: donorPhone,
        donorCedula: donorCedula,
        donorRnc: donorRnc,
        withReceipt: withReceipt,
        paymentMethod: paymentMethod,
        concept: concept,
        amount: amount,
        date: date,
        token: token,
      );

      state = const AsyncValue.data(null);
      return donation.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<String?> getPdfUrl(int donationId) async {
    try {
      final token = ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(donationRepositoryProvider);
      return await repo.getPdfUrl(donationId, token);
    } catch (e) {
      return null;
    }
  }
}
