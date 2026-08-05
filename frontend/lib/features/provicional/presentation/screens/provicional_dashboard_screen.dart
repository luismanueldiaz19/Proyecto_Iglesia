import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../widgets/ingresos_filter_widget.dart';
import '../widgets/total_summary_widget.dart';
import '../widgets/dashboard_chart_widget.dart';

class ProvicionalDashboardScreen extends StatefulWidget {
  const ProvicionalDashboardScreen({super.key});

  @override
  State<ProvicionalDashboardScreen> createState() =>
      _ProvicionalDashboardScreenState();
}

class _ProvicionalDashboardScreenState
    extends State<ProvicionalDashboardScreen> {
  bool _isLoading = true;
  String _selectedQuickFilter = 'Este año';
  DateTime? _startDate;
  DateTime? _endDate;

  double _totalIngresos = 0;
  double _totalGastos = 0;
  double _balance = 0;
  List<dynamic> _chartData = [];

  @override
  void initState() {
    super.initState();
    _applyQuickFilter(_selectedQuickFilter);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};

      if (_startDate != null && _endDate != null) {
        queryParams['start_date'] =
            '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
        queryParams['end_date'] =
            '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/provicional-dashboard',
      ).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalIngresos =
              double.tryParse(data['totales']['ingresos']?.toString() ?? '0') ??
              0;
          _totalGastos =
              double.tryParse(data['totales']['gastos']?.toString() ?? '0') ??
              0;
          _balance =
              double.tryParse(data['totales']['balance']?.toString() ?? '0') ??
              0;
          _chartData = data['grafica_mensual'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _selectedQuickFilter = filter;
      final now = DateTime.now();
      switch (filter) {
        case 'Hoy':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Ayer':
          _startDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 1));
          _endDate = DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          ).subtract(const Duration(days: 1));
          break;
        case 'Esta semana':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = _startDate!.add(
            const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
          );
          break;
        case 'Este mes':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'Mes pasado':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'Este año':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case 'Personalizado':
          return;
      }
    });
    _loadData();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedQuickFilter = 'Personalizado';
        _startDate = picked.start;
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });
      _loadData();
    }
  }

  void _selectMonth(int index) {
    if (index == 0) return;
    setState(() {
      _selectedQuickFilter = 'Personalizado';
      final now = DateTime.now();
      _startDate = DateTime(now.year, index, 1);
      _endDate = DateTime(now.year, index + 1, 0, 23, 59, 59);
    });
    _loadData();
  }

  Future<void> _downloadPdf() async {
    try {
      final queryParams = <String, String>{};
      if (_startDate != null && _endDate != null) {
        queryParams['start_date'] =
            '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
        queryParams['end_date'] =
            '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/provicional-dashboard/pdf',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Guardar reporte PDF',
          fileName: 'dashboard_provisionales.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          if (!outputFile.endsWith('.pdf')) {
            outputFile += '.pdf';
          }
          final file = File(outputFile);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reporte guardado en: $outputFile')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al generar PDF: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const PageHeader(
            title: 'Dashboard Provisionales',
            subtitle: 'Comparativa de Ingresos vs Gastos Provisionales',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter widget without search and excel imports
                  IngresosFilterWidget(
                    selectedQuickFilter: _selectedQuickFilter,
                    onQuickFilterChanged: _applyQuickFilter,
                    onDateRangeSelected: _selectDateRange,
                    onMonthSelected: _selectMonth,
                    onDownloadPdf: _downloadPdf,
                    onShowInfo: () {},
                    isUploading: false,
                    showSearchAndExport: false,
                  ),
                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: TotalSummaryWidget(
                          title: 'Total Ingresos',
                          totalAmount: _totalIngresos,
                          icon: Icons.arrow_downward,
                          accentColor: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TotalSummaryWidget(
                          title: 'Total Gastos',
                          totalAmount: _totalGastos,
                          icon: Icons.arrow_upward,
                          accentColor: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TotalSummaryWidget(
                          title: 'Balance General',
                          totalAmount: _balance,
                          icon: Icons.account_balance,
                          accentColor: _balance >= 0
                              ? Colors.blue.shade600
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : DashboardChartWidget(chartData: _chartData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
