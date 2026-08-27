import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/pending_task_model.dart';

class PendingTaskRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders(String token) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<PendingTaskModel>> getPendingTasks(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pending-tasks'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PendingTaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pending tasks');
    }
  }

  Future<PendingTaskModel> createPendingTask(
    String token,
    PendingTaskModel task,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pending-tasks'),
      headers: await _getHeaders(token),
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return PendingTaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create pending task: ${response.body}');
    }
  }

  Future<PendingTaskModel> updatePendingTask(
    String token,
    int id,
    PendingTaskModel task,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/pending-tasks/$id'),
      headers: await _getHeaders(token),
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return PendingTaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update pending task: ${response.body}');
    }
  }

  Future<void> deletePendingTask(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/pending-tasks/$id'),
      headers: await _getHeaders(token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete pending task');
    }
  }

  Future<String> getPdfUrl(
    String token, {
    String? filter,
    String? searchQuery,
    int? month,
    int? year,
  }) async {
    final uri = Uri.parse('$_baseUrl/pending-tasks/pdf-url').replace(
      queryParameters: {
        if (filter != null && filter != 'Todos') 'status': filter,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        if (month != null) 'month': month.toString(),
        if (year != null) 'year': year.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: await _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to generate PDF URL');
    }
  }
}
