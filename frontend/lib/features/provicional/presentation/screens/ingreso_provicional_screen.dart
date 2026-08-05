import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../core/presentation/widgets/excel_format_info_dialog.dart';
import '../widgets/ingresos_chart_widget.dart';
import '../widgets/ingresos_table_widget.dart';
import '../widgets/ingresos_filter_widget.dart';
import '../widgets/total_summary_widget.dart';
import '../widgets/nuevo_ingreso_dialog.dart';

class IngresoProvicionalScreen extends StatefulWidget {
  const IngresoProvicionalScreen({super.key});

  @override
  State<IngresoProvicionalScreen> createState() =>
      _IngresoProvicionalScreenState();
}

class _IngresoProvicionalScreenState extends State<IngresoProvicionalScreen> {
  bool _isUploading = false;
  List<dynamic> _ingresos = [];
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
    return _ingresos.fold(0.0, (sum, item) {
      final montoStr = item['monto']?.toString() ?? '0';
      final monto = double.tryParse(montoStr) ?? 0.0;
      return sum + monto;
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

      String url = '${ApiConfig.baseUrl}/ingresos-provicionales';
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
            _ingresos = data;
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
        Uri.parse('${ApiConfig.baseUrl}/ingresos-provicionales-chart'),
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
      FilePickerResult? result = await FilePicker.pickFiles(
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
          Uri.parse('${ApiConfig.baseUrl}/ingresos-provicionales/import'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

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
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Guardar reporte',
          fileName: defaultFileName,
          type: FileType.custom,
          allowedExtensions: [extension],
        );

        if (outputFile != null) {
          if (!outputFile.endsWith('.$extension')) {
            outputFile += '.$extension';
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
    const String csvData = "fecha_ingreso,concepto,monto\n";
    try {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Guardar plantilla',
        fileName: 'plantilla_ingresos.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.csv')) {
          outputFile += '.csv';
        }
        final file = File(outputFile);
        await file.writeAsString(csvData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plantilla guardada en: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveNuevoIngreso(Map<String, dynamic> formData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ingresos-provicionales'),
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
            const SnackBar(content: Text('Ingreso guardado exitosamente')),
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
        'fecha_ingreso':
            'Formato MES/DIA/AÑO (ej. 6/25/2026), DD/MM/YYYY, YYYY-MM-DD o Fecha nativa de Excel.',
        'concepto': 'Descripción del ingreso.',
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
              title: 'Ingresos',
              subtitle:
                  'Gestión, registro y reportes de ingresos de la iglesia',
              actionButton: ElevatedButton.icon(
                onPressed: () {
                  _showCreateDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Ingreso'),
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
            IngresosFilterWidget(
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
                    child: IngresosTableWidget(
                      isLoading: _isLoading,
                      ingresos: _ingresos,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        TotalSummaryWidget(
                          title: 'Total Ingresos',
                          totalAmount: _totalMonto,
                          icon: Icons.account_balance_wallet,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: IngresosChartWidget(
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
    NuevoIngresoDialog.show(
      context,
      onSave: (formData) {
        _saveNuevoIngreso(formData);
      },
    );
  }
}
