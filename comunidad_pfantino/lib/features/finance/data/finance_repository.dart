import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../accounting/data/models/accounting_account_model.dart';
import 'models/journal_entry_model.dart';
import 'models/journal_entry_line_model.dart';

class FinanceRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders(String token) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<JournalEntryModel>> getJournalEntries(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/journal-entries'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List data = jsonResponse['data'] ?? []; // It's paginated, so 'data'
      return data.map((json) => JournalEntryModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar diario general: ${response.body}');
    }
  }

  Future<List<JournalEntryLineModel>> getLedger(
    String token,
    int accountId,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ledger/$accountId'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => JournalEntryLineModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar libro mayor: ${response.body}');
    }
  }

  Future<List<AccountingAccountModel>> getAccounts(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/accounts'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => AccountingAccountModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar cuentas: ${response.body}');
    }
  }
}
