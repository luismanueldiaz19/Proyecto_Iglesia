import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/accounting_engine_config_model.dart';

class AccountingEngineConfigRepository {
  final LocalStorage _localStorage;

  AccountingEngineConfigRepository(this._localStorage);

  Map<String, String> get _headers {
    final token = _localStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AccountingEngineConfigModel>> getConfigs() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/accounting-configs'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AccountingEngineConfigModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar configuraciones contables');
    }
  }

  Future<AccountingEngineConfigModel> createConfig(AccountingEngineConfigModel config) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/accounting-configs'),
      headers: _headers,
      body: jsonEncode(config.toJson()),
    );

    if (response.statusCode == 201) {
      return AccountingEngineConfigModel.fromJson(jsonDecode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear la configuración');
    }
  }

  Future<void> deleteConfig(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/accounting-configs/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al eliminar la configuración');
    }
  }
}
