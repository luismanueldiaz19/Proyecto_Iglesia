import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_config.dart';
import '../models/bank_account_model.dart';
import '../models/bank_model.dart';
import '../models/bank_transaction_model.dart';
import '../models/bank_reconciliation_model.dart';

class BankRepository {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // --- Banks ---
  Future<List<Bank>> getBanks() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/banks'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Bank.fromJson(json)).toList();
    }
    throw Exception('Failed to load banks');
  }

  // --- Bank Accounts ---
  Future<List<BankAccount>> getBankAccounts() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/bank-accounts'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BankAccount.fromJson(json)).toList();
    }
    throw Exception('Failed to load bank accounts');
  }

  Future<BankAccount> getBankAccountDetails(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/bank-accounts/$id'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return BankAccount.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load bank account details');
  }

  Future<BankAccount> createBankAccount(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bank-accounts'),
      headers: _headers(token),
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return BankAccount.fromJson(json.decode(response.body));
    }
    throw Exception(
      'Failed to create bank account: ${response.statusCode} - ${response.body}',
    );
  }

  // --- Bank Transactions ---
  Future<List<BankTransaction>> getTransactionsForAccount(int accountId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/bank-transactions?bank_account_id=$accountId',
      ),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BankTransaction.fromJson(json)).toList();
    }
    throw Exception('Failed to load transactions');
  }

  Future<BankTransaction> createTransaction(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bank-transactions'),
      headers: _headers(token),
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return BankTransaction.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create transaction');
  }

  // --- Bank Reconciliations ---
  Future<BankReconciliation> createReconciliation(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bank-reconciliations'),
      headers: _headers(token),
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return BankReconciliation.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to start reconciliation');
  }

  Future<BankReconciliation> updateReconciliation(
    int id,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/bank-reconciliations/$id'),
      headers: _headers(token),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return BankReconciliation.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update reconciliation');
  }
}
