import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/accounting_account_model.dart';

class AccountingRepository {
  final LocalStorage _localStorage;

  AccountingRepository(this._localStorage);

  Future<Map<String, String>> _getHeaders() async {
    final token = _localStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<AccountingAccountModel>> getAccounts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.accounts),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => AccountingAccountModel.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Error al cargar las cuentas';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw 'Fallo de conexión al servidor al cargar cuentas.';
    }
  }

  Future<AccountingAccountModel> createAccount(
    AccountingAccountModel account,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.accounts),
        headers: await _getHeaders(),
        body: jsonEncode(account.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AccountingAccountModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        if (response.statusCode == 422) {
          // Extraer el primer error de validación
          final errors = errorData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first[0];
          throw firstError;
        }
        throw errorData['message'] ?? 'Error al crear la cuenta';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw 'Fallo de conexión al servidor.';
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.accounts}/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Error al eliminar la cuenta';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw 'Fallo de conexión al servidor.';
    }
  }
}
