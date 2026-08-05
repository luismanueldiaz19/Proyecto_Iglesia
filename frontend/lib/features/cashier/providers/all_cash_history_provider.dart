import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/cash_reconciliation_model.dart';
import 'cash_provider.dart';

class AllCashHistoryState {
  final bool isLoading;
  final String? error;
  final List<CashReconciliationModel> reconciliations;
  final int? selectedModuleId;
  final DateTime startDate;
  final DateTime endDate;

  AllCashHistoryState({
    this.isLoading = false,
    this.error,
    this.reconciliations = const [],
    this.selectedModuleId,
    required this.startDate,
    required this.endDate,
  });

  AllCashHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<CashReconciliationModel>? reconciliations,
    int? selectedModuleId,
    bool clearModuleId = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return AllCashHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      reconciliations: reconciliations ?? this.reconciliations,
      selectedModuleId: clearModuleId
          ? null
          : (selectedModuleId ?? this.selectedModuleId),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AllCashHistoryNotifier extends StateNotifier<AllCashHistoryState> {
  final Ref ref;

  AllCashHistoryNotifier(this.ref)
    : super(
        AllCashHistoryState(
          startDate: DateTime(DateTime.now().year, 1, 1),
          endDate: DateTime(DateTime.now().year, 12, 31),
        ),
      ) {
    fetchReconciliations();
  }

  Future<String?> _getToken() async {
    return ref.read(authProvider.notifier).getToken();
  }

  Future<void> fetchReconciliations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final repo = ref.read(cashRepositoryProvider);

      final startDateStr =
          "${state.startDate.year}-${state.startDate.month.toString().padLeft(2, '0')}-${state.startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${state.endDate.year}-${state.endDate.month.toString().padLeft(2, '0')}-${state.endDate.day.toString().padLeft(2, '0')}";

      final results = await repo.getAllReconciliations(
        token,
        moduleId: state.selectedModuleId,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      state = state.copyWith(isLoading: false, reconciliations: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter({
    int? moduleId,
    bool clearModuleId = false,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      selectedModuleId: moduleId,
      clearModuleId: clearModuleId,
      startDate: startDate,
      endDate: endDate,
    );
    fetchReconciliations();
  }

  Future<String?> downloadPdf() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No autenticado');

      final startDateStr =
          "${state.startDate.year}-${state.startDate.month.toString().padLeft(2, '0')}-${state.startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${state.endDate.year}-${state.endDate.month.toString().padLeft(2, '0')}-${state.endDate.day.toString().padLeft(2, '0')}";

      final queryParams = <String, String>{
        'start_date': startDateStr,
        'end_date': endDateStr,
      };

      if (state.selectedModuleId != null) {
        queryParams['module_id'] = state.selectedModuleId.toString();
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/cash-reconciliations/all/pdf',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        String? outputFile = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Guardar reporte PDF',
          fileName: 'historial_cuadres.pdf',
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          if (!outputFile.endsWith('.pdf')) {
            outputFile += '.pdf';
          }
          final file = File(outputFile);
          await file.writeAsBytes(response.bodyBytes);
          return outputFile;
        }
        return null;
      } else {
        throw Exception('Error al generar PDF: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final allCashHistoryProvider =
    StateNotifierProvider<AllCashHistoryNotifier, AllCashHistoryState>((ref) {
      return AllCashHistoryNotifier(ref);
    });
