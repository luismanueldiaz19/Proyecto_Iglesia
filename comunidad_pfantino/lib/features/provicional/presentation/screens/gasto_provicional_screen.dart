import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../core/presentation/widgets/excel_format_info_dialog.dart';
import '../../../finance/bank/presentation/widgets/bank_account_selector_dialog.dart';
import '../widgets/gastos_chart_widget.dart';
import '../widgets/gastos_table_widget.dart';
import '../widgets/gastos_filter_widget.dart';
import '../widgets/total_summary_widget.dart';
import '../widgets/check_count_summary_widget.dart';
import '../widgets/nuevo_gasto_dialog.dart';

class GastoProvicionalScreen extends StatefulWidget {
  const GastoProvicionalScreen({super.key});

  @override
  State<GastoProvicionalScreen> createState() => _GastoProvicionalScreenState();
}

class _GastoProvicionalScreenState extends State<GastoProvicionalScreen> {
  bool _isUploading = false;
  List<dynamic> _gastos = [];
  bool _isLoading = false;
  String _selectedQuickFilter = 'Este año';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  List<dynamic> _chartData = [];
  bool _isLoadingChart = false;

  @override
  void initState() {
    super.initState();
    _applyQuickFilter('Este año');
    _loadChartData();
  }

  double get _totalMonto {
    return _gastos.fold(0.0, (sum, item) {
      final montoStr = item['monto']?.toString() ?? '0';
      final monto = double.tryParse(montoStr) ?? 0.0;
      return sum + monto;
    });
  }

  int get _uniqueCheckCount {
    final checks = _gastos
        .map((g) => g['num_check']?.toString().trim())
        .where((c) => c != null && c.isNotEmpty)
        .toSet();
    return checks.length;
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

      String url = '${ApiConfig.baseUrl}/gastos-provicionales';
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
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _gastos = data;
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
        Uri.parse('${ApiConfig.baseUrl}/gastos-provicionales-chart'),
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

  Future<void> _uploadExcel() async {
    try {
      final bankAccountId = await BankAccountSelectorDialog.show(context);

      if (bankAccountId == null) {
        return; // User cancelled
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
        });

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('api_token');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/gastos-provicionales/import'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        request.fields['bank_account_id'] = bankAccountId.toString();

        request.files.add(
          await http.MultipartFile.fromPath('file', result.files.single.path!),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excel importado exitosamente')),
            );
            _loadData();
            _loadChartData();
          }
        } else {
          final respStr = await response.stream.bytesToString();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al importar: $respStr')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _downloadFile(
    String endpoint,
    String defaultFileName,
    String extension,
  ) async {
    setState(() => _isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
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
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _downloadPdf() => _downloadFile(
    'provicional-reportes/pdf',
    'reporte_provicional.pdf',
    'pdf',
  );
  void _downloadExcel() => _downloadFile(
    'provicional-reportes/excel',
    'reporte_provicional.xlsx',
    'xlsx',
  );

  Future<void> _downloadTemplate() async {
    const String csvData = "fecha_gasto,concepto,num_check,monto\n";
    try {
      final bytes = Uint8List.fromList(utf8.encode(csvData));
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar plantilla',
        fileName: 'plantilla_gastos.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: bytes,
      );

      if (outputFile != null && !kIsWeb) {
        if (!outputFile.endsWith('.csv')) {
          outputFile += '.csv';
        }
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plantilla descargada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveNuevogasto(Map<String, dynamic> formData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/gastos-provicionales'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('gasto guardado exitosamente')),
          );
          _loadData();
          _loadChartData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    ExcelFormatInfoDialog.show(
      context,
      expectedColumns: {
        'fecha_gasto':
            'Formato MES/DIA/AÑO (ej. 6/25/2026), DD/MM/YYYY, YYYY-MM-DD o Fecha nativa de Excel.',
        'concepto': 'Descripción del gasto.',
        'num_check': 'Opcional. Número de cheque.',
        'monto': 'Valor numérico mayor a 0.',
      },
      onDownloadTemplate: _downloadTemplate,
    );
  }

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
              title: 'Gastos',
              subtitle: 'Gestión, registro y reportes de gastos de la iglesia',
              actionButton: ElevatedButton.icon(
                onPressed: () {
                  _showCreateDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Gasto'),
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
              ),
            ),
            const SizedBox(height: 24),
            GastosFilterWidget(
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
              onUploadExcel: _uploadExcel,
              onShowInfo: () => _showInfoDialog(context),
              isUploading: _isUploading,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: GastosTableWidget(
                      isLoading: _isLoading,
                      gastos: _gastos,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          child: Row(
                            children: [
                              Expanded(
                                child: TotalSummaryWidget(
                                  title: 'Total Gastos',
                                  totalAmount: _totalMonto,
                                  icon: Icons.account_balance_wallet,
                                  accentColor: const Color(0xFFB91C1C),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CheckCountSummaryWidget(
                                  uniqueCheckCount: _uniqueCheckCount,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GastosChartWidget(
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

  void _showCreateDialog(BuildContext context) {
    NuevoGastoDialog.show(
      context,
      onSave: (formData) {
        _saveNuevogasto(formData);
      },
    );
  }
}
