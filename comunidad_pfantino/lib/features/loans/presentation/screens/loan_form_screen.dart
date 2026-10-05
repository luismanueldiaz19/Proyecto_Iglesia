import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loan_provider.dart';
import '../../data/models/loan_model.dart';
import 'package:intl/intl.dart';

class LoanFormScreen extends ConsumerStatefulWidget {
  const LoanFormScreen({super.key});

  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lenderNameController = TextEditingController();
  final _loanNumberController = TextEditingController();
  final _memberNumberController = TextEditingController();
  final _debtorNameController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _monthlyRateController = TextEditingController();
  final _termMonthsController = TextEditingController();
  final _installmentAmountController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _lenderNameController.dispose();
    _loanNumberController.dispose();
    _memberNumberController.dispose();
    _debtorNameController.dispose();
    _originalAmountController.dispose();
    _monthlyRateController.dispose();
    _termMonthsController.dispose();
    _installmentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : (_dueDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loan = LoanModel(
        lenderName: _lenderNameController.text.trim(),
        loanNumber: _loanNumberController.text.trim(),
        memberNumber: _memberNumberController.text.trim().isEmpty
            ? null
            : _memberNumberController.text.trim(),
        debtorName: _debtorNameController.text.trim().isEmpty
            ? null
            : _debtorNameController.text.trim(),
        startDate: _startDate,
        dueDate: _dueDate,
        originalAmount: double.parse(
          _originalAmountController.text.replaceAll(',', ''),
        ),
        currentBalance: double.parse(
          _originalAmountController.text.replaceAll(',', ''),
        ),
        monthlyRate: double.parse(
          _monthlyRateController.text.replaceAll(',', ''),
        ),
        termMonths: int.parse(_termMonthsController.text),
        installmentAmount: double.parse(
          _installmentAmountController.text.replaceAll(',', ''),
        ),
        modality: 'INTERES_CAPITAL_CUOTA_FIJA',
        status: 'active',
      );

      await ref.read(loanProvider.notifier).createLoan(loan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préstamo registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Préstamo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Datos del Prestamista / Socio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _lenderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Prestamista (ej. CoopCupadec)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _loanNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Número de Préstamo',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _memberNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Número de Socio',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _debtorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Deudor',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Condiciones Financieras',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _originalAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Monto Original',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _monthlyRateController,
                            decoration: const InputDecoration(
                              labelText: 'Tasa Mensual (%)',
                              suffixText: '%',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _termMonthsController,
                            decoration: const InputDecoration(
                              labelText: 'Plazo (Meses)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _installmentAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Valor Cuota Regular',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Fecha de Préstamo'),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(_startDate),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListTile(
                            title: const Text('Fecha Vencimiento (Opcional)'),
                            subtitle: Text(
                              _dueDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                  : 'Seleccionar',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Guardar Préstamo'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
