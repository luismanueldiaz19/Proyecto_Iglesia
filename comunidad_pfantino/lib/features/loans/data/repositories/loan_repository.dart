import 'dart:convert';
import 'package:comunidad_pfantino/core/network/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';

class LoanRepository {
  final http.Client client;

  LoanRepository({required this.client});

  Future<List<LoanModel>> getLoans(String token) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/loans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LoanModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar préstamos');
    }
  }
  Future<Map<String, dynamic>> getLoanDetails(int id, String token) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/loans/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar detalles del préstamo');
    }
  }
  Future<LoanModel> createLoan(LoanModel loan, String token) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/loans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(loan.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return LoanModel.fromJson(data['loan']);
    } else {
      throw Exception('Error al crear el préstamo: ${response.body}');
    }
  }

  Future<LoanModel> updateLoan(int id, LoanModel loan, String token) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/loans/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(loan.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LoanModel.fromJson(data['loan']);
    } else {
      throw Exception('Error al actualizar el préstamo: ${response.body}');
    }
  }



  Future<Map<String, dynamic>> applyPayment(
    int loanId,
    Map<String, dynamic> paymentData,
    String token,
  ) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(paymentData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al aplicar el pago: ${response.body}');
    }
  }
}

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepository(client: http.Client());
});
