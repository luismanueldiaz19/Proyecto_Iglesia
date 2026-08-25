import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_config.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class NuevoGastoDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const NuevoGastoDialog({super.key, required this.onSave});

  static void show(BuildContext context, {required Function(Map<String, dynamic>) onSave}) {
    showDialog(
      context: context,
      builder: (context) => NuevoGastoDialog(onSave: onSave),
    );
  }

  @override
  State<NuevoGastoDialog> createState() => _NuevoGastoDialogState();
}

class _NuevoGastoDialogState extends State<NuevoGastoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _conceptoController = TextEditingController();
  final _numCheckController = TextEditingController();
  final _montoController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoadingBanks = false;
  List<dynamic> _bankAccounts = [];
  int? _selectedBankAccountId;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    setState(() => _isLoadingBanks = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bank-accounts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _bankAccounts = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading bank accounts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBanks = false);
      }
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _conceptoController.dispose();
    _numCheckController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'fecha_gasto': _fechaController.text,
        'concepto': _conceptoController.text,
        'num_check': _numCheckController.text.isNotEmpty ? _numCheckController.text : null,
        'monto': double.parse(_montoController.text),
        'bank_account_id': _selectedBankAccountId,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo Gasto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 24),
              // Fecha Field
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  hintText: 'Seleccionar fecha',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.red.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              // Concepto Field
              TextFormField(
                controller: _conceptoController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: InputDecoration(
                  labelText: 'Concepto',
                  hintText: 'Descripción del gasto',
                  prefixIcon: Icon(Icons.description, color: Colors.red.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              // Num Check Field
              TextFormField(
                controller: _numCheckController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: InputDecoration(
                  labelText: 'Número de Cheque',
                  hintText: 'Opcional',
                  prefixIcon: Icon(Icons.tag, color: Colors.red.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Monto Field
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Monto',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.red.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Origen Field
              if (_isLoadingBanks)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _selectedBankAccountId,
                  decoration: InputDecoration(
                    labelText: 'Origen (Cuenta o Caja)',
                    hintText: 'Seleccione de dónde salió el dinero',
                    prefixIcon: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.red.shade600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.red.shade600,
                        width: 2,
                      ),
                    ),
                  ),
                  items: _bankAccounts.map((account) {
                    final bankName = account['bank'] != null
                        ? account['bank']['name']
                        : 'Banco';
                    final accNum = account['account_number'] ?? '';
                    final suffix = accNum.toString().isNotEmpty ? ' ($accNum)' : '';
                    
                    return DropdownMenuItem<int>(
                      value: account['id'],
                      child: Text(
                        '$bankName - ${account['name']}$suffix',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankAccountId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione un origen' : null,
                ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
