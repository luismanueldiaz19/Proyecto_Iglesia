import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../provicional/presentation/widgets/total_summary_widget.dart';
import '../widgets/donations_chart_widget.dart';
import '../widgets/donations_table_widget.dart';
import '../widgets/donations_filter_widget.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  bool _isDownloading = false;
  List<dynamic> _donations = [];
  bool _isLoading = false;
  String _selectedQuickFilter = 'Este año';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  List<dynamic> _chartData = [];
  bool _isLoadingChart = false;
  String _selectedPaymentMethod = 'Todos';
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _applyQuickFilter('Este año');
    _loadChartData();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('role');
      });
    }
  }

  double get _totalAmount {
    return _donations.fold(0.0, (sum, item) {
      final amountStr = item['amount']?.toString() ?? '0';
      final amount = double.tryParse(amountStr) ?? 0.0;
      return sum + amount;
    });
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      String url = '${ApiConfig.baseUrl}/donations';
      List<String> queryParams = [];
      if (_startDate != null) {
        queryParams.add('start_date=${_formatDateForApi(_startDate!)}');
      }
      if (_endDate != null) {
        queryParams.add('end_date=${_formatDateForApi(_endDate!)}');
      }
      if (_searchQuery.isNotEmpty) {
        queryParams.add('search=$_searchQuery');
      }
      if (_selectedPaymentMethod != 'Todos') {
        queryParams.add('payment_method=$_selectedPaymentMethod');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _donations = data is List ? data : data['data'] ?? [];
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar datos: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoadingChart = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations-chart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _chartData = jsonDecode(response.body);
          });
        }
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) {
        setState(() => _isLoadingChart = false);
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
          _endDate = DateTime(now.year, now.month, now.day);
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
          ).subtract(const Duration(days: 1));
          break;
        case 'Esta semana':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'Este mes':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Mes pasado':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'Este año':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
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
    );

    if (picked != null) {
      setState(() {
        _selectedQuickFilter = 'Personalizado';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  void _selectMonth(int month) {
    final now = DateTime.now();
    setState(() {
      _selectedQuickFilter = 'Personalizado';
      _startDate = DateTime(now.year, month, 1);
      _endDate = DateTime(
        now.year,
        month + 1,
        0,
      ); // 0 means the last day of the previous month (which is our target month)
    });
    _loadData();
  }

  Future<void> _downloadFile(
    String endpoint,
    String defaultFileName,
    String extension,
  ) async {
    setState(() => _isDownloading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      String url = '${ApiConfig.baseUrl}/$endpoint';
      List<String> queryParams = [];
      if (_startDate != null) {
        queryParams.add('start_date=${_formatDateForApi(_startDate!)}');
      }
      if (_endDate != null) {
        queryParams.add('end_date=${_formatDateForApi(_endDate!)}');
      }
      if (_searchQuery.isNotEmpty) {
        queryParams.add('search=$_searchQuery');
      }
      if (_selectedPaymentMethod != 'Todos') {
        queryParams.add('payment_method=$_selectedPaymentMethod');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar reporte',
          fileName: defaultFileName,
          type: FileType.custom,
          allowedExtensions: [extension],
          bytes: response.bodyBytes,
        );

        if (outputFile != null && !kIsWeb) {
          if (!outputFile.endsWith('.$extension')) {
            outputFile += '.$extension';
          }
          final file = File(outputFile);
          await file.writeAsBytes(response.bodyBytes);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte guardado exitosamente')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al generar reporte: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _printDonation(int donationId, String donorName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      // 1. Obtener la URL del PDF firmada
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations/$donationId/pdf-url'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['url'];

        // 2. Abrir la URL firmada directamente en el navegador
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No se pudo abrir el enlace del recibo.');
        }
      } else {
        throw Exception('Error al obtener URL del PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el recibo: $e')),
        );
      }
    }
  }

  void _downloadPdf() =>
      _downloadFile('donations/export/pdf', 'historial_donaciones.pdf', 'pdf');

  void _downloadExcel() => _downloadFile(
    'donations/export/excel',
    'historial_donaciones.xlsx',
    'xlsx',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Historial de Donaciones',
              subtitle: 'Consulta, filtra y exporta el historial de donaciones',
              actionButton: ['Administrador', 'Supervisor', 'Operativo', 'admin'].contains(_userRole)
                  ? ElevatedButton.icon(
                      onPressed: () {
                        context.go('/donations/create');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Donación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChurchColors.primary,
                        foregroundColor: ChurchColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            DonationsFilterWidget(
              selectedQuickFilter: _selectedQuickFilter,
              onQuickFilterChanged: _applyQuickFilter,
              onDateRangeSelected: _selectDateRange,
              onMonthSelected: _selectMonth,
              onSearchQueryChanged: (val) {
                _searchQuery = val;
              },
              onSearchSubmitted: _loadData,
              onDownloadPdf: _downloadPdf,
              onDownloadExcel: _downloadExcel,
              selectedPaymentMethod: _selectedPaymentMethod,
              onPaymentMethodChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
                _loadData();
              },
            ),
            if (_isDownloading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: DonationsTableWidget(
                      isLoading: _isLoading,
                      donations: _donations,
                      onPrint: _printDonation,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        TotalSummaryWidget(
                          title: 'Total Donaciones',
                          totalAmount: _totalAmount,
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: DonationsChartWidget(
                            isLoading: _isLoadingChart,
                            chartData: _chartData,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
