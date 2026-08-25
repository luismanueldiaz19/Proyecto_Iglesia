import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';

import '../models/cash_reconciliation_model.dart';
import '../models/cash_transaction_model.dart';
import '../models/denomination_model.dart';
import '../models/module_model.dart';

class CashRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders(String token) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ModuleModel>> getModules(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/modules'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ModuleModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar módulos: ${response.body}');
    }
  }

  Future<List<DenominationModel>> getDenominations(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/denominations'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => DenominationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar denominaciones: ${response.body}');
    }
  }

  Future<List<CashReconciliationModel>> getAllReconciliations(
    String token, {
    int? moduleId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParams = {};
    if (moduleId != null) queryParams['module_id'] = moduleId.toString();
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.parse('$_baseUrl/cash-reconciliations/all')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CashReconciliationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar todos los cuadres: ${response.body}');
    }
  }

  Future<CashReconciliationModel?> getCurrentReconciliation(
    String token,
    int moduleId,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cash-reconciliations/current/$moduleId'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return CashReconciliationModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al verificar la caja actual: ${response.body}');
    }
  }

  Future<List<CashReconciliationModel>> getReconciliationHistory(
    String token,
    int moduleId,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/modules/$moduleId/reconciliations'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List items = data['data']; // Laravel paginator
      return items
          .map((json) => CashReconciliationModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error al cargar el historial de cuadres: ${response.body}',
      );
    }
  }

  Future<CashReconciliationModel> getReconciliationDetails(
    String token,
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cash-reconciliations/$id'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return CashReconciliationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar detalles del cuadre: ${response.body}');
    }
  }

  Future<String> getPdfUrl(String token, int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cash-reconciliations/$id/pdf-url'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['url'];
    } else {
      throw Exception('Error al obtener URL del PDF: ${response.body}');
    }
  }

  Future<String> getTemplatePdfUrl(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cash-reconciliations/template/pdf-url'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['url'];
    } else {
      throw Exception('Error al obtener URL de la plantilla PDF: ${response.body}');
    }
  }

  Future<String> getAllReconciliationsPdfUrl(
    String token, {
    int? moduleId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParams = {};
    if (moduleId != null) queryParams['module_id'] = moduleId.toString();
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.parse('$_baseUrl/cash-reconciliations/all/pdf-url')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['url'];
    } else {
      throw Exception('Error al obtener URL del PDF de todos los cuadres: ${response.body}');
    }
  }

  Future<void> depositReconciliation(
    String token,
    int id,
    int accountId,
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cash-reconciliations/$id/deposit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'account_id': accountId, 'amount': amount}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = jsonDecode(response.body);
      final errorMsg = body['error'] ?? body['message'] ?? 'Error desconocido';
      throw Exception('Error al depositar: $errorMsg');
    }
  }

  Future<CashReconciliationModel> openCashReconciliation(
    String token,
    int moduleId, {
    String? date,
  }) async {
    final Map<String, dynamic> body = {'module_id': moduleId};
    if (date != null) {
      body['date'] = date;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/cash-reconciliations'),
      headers: await _getHeaders(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return CashReconciliationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al abrir la caja: ${response.body}');
    }
  }

  Future<CashReconciliationModel> closeCashReconciliation(
    String token,
    int reconciliationId,
    List<Map<String, dynamic>> denominations,
    double totalGeneral, {
    String? notes,
  }) async {
    final Map<String, dynamic> body = {
      'denominations': denominations,
      'total_general': totalGeneral,
    };
    if (notes != null) {
      body['notes'] = notes;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/cash-reconciliations/$reconciliationId/close'),
      headers: await _getHeaders(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return CashReconciliationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cerrar la caja: ${response.body}');
    }
  }

  Future<CashTransactionModel> addTransaction(
    String token,
    int reconciliationId,
    int accountId,
    double amount,
    String type,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cash-transactions'),
      headers: await _getHeaders(token),
      body: jsonEncode({
        'cash_reconciliation_id': reconciliationId,
        'account_id': accountId,
        'amount': amount,
        'type': type,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return CashTransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar transacción: ${response.body}');
    }
  }

  Future<CashTransactionModel> updateTransaction(
    String token,
    int transactionId,
    int accountId,
    double amount,
    String type,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/cash-transactions/$transactionId'),
      headers: await _getHeaders(token),
      body: jsonEncode({
        'account_id': accountId,
        'amount': amount,
        'type': type,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return CashTransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar transacción: ${response.body}');
    }
  }
}
