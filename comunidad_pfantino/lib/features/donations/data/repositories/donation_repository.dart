import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_config.dart';
import '../models/donation_model.dart';

final donationRepositoryProvider = Provider((ref) => DonationRepository());

class DonationRepository {
  Future<DonationModel> createDonation({
    required String donorName,
    String? donorPhone,
    String? donorCedula,
    String? donorRnc,
    required bool withReceipt,
    required String paymentMethod,
    required String concept,
    required double amount,
    DateTime? date,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/donations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'donor_name': donorName,
        'donor_phone': donorPhone,
        'donor_cedula': donorCedula,
        'donor_rnc': donorRnc,
        'with_receipt': withReceipt,
        'payment_method': paymentMethod,
        'concept': concept,
        'amount': amount,
        if (date != null) 'created_at': date.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return DonationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear donación: ${response.body}');
    }
  }

  Future<String> getPdfUrl(int donationId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/donations/$donationId/pdf-url'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Error al obtener URL del PDF');
    }
  }
}
