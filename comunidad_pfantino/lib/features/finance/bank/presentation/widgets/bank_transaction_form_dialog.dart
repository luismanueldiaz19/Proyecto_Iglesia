import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/church_colors.dart';
import '../../data/repositories/bank_repository.dart';

class BankTransactionFormDialog extends StatefulWidget {
  final int bankAccountId;

  const BankTransactionFormDialog({
    super.key,
    required this.bankAccountId,
  });

  @override
  State<BankTransactionFormDialog> createState() =>
      _BankTransactionFormDialogState();
}

class _BankTransactionFormDialogState extends State<BankTransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repository = BankRepository();

  bool _isLoading = false;

  // Controllers
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'deposit'; // 'deposit' or 'withdrawal'

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      double rawAmount = double.tryParse(_amountController.text) ?? 0.0;
      // Withdrawals should generally be stored as negative or the API handles it based on type.
      // We will let the API handle the type, or we pass negative if it's withdrawal.
      // Assuming the API expects the exact amount and a type, or just a negative amount.
      // For now we pass amount and type, if API expects negative for withdrawals, we convert it here.
      double amount = _transactionType == 'withdrawal' ? -rawAmount : rawAmount;

      await _repository.createTransaction({
        'bank_account_id': widget.bankAccountId,
        'type': _transactionType,
        'amount': amount,
        'date': _selectedDate.toIso8601String(),
        'reference': _referenceController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'transit',
      });

      if (mounted) {
        Navigator.of(context).pop(true); // Signal success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear transacción: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva Transacción',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ChurchColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _transactionType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Transacción',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'deposit',
                          child: Text('Depósito'),
                        ),
                        DropdownMenuItem(
                          value: 'withdrawal',
                          child: Text('Retiro'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _transactionType = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Número de Referencia / Cheque',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChurchColors.primary,
                      foregroundColor: ChurchColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar Transacción'),
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
