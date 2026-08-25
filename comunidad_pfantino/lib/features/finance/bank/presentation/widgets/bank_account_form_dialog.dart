import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/storage/local_storage.dart';
import '../../../../../core/theme/church_colors.dart';
import '../../../../../core/presentation/widgets/modern_loading_overlay.dart';
import '../../../../accounting/data/models/accounting_account_model.dart';
import '../../../../accounting/data/repositories/accounting_repository.dart';
import '../../data/models/bank_model.dart';
import '../../data/repositories/bank_repository.dart';

class BankAccountFormDialog extends StatefulWidget {
  const BankAccountFormDialog({super.key});

  @override
  State<BankAccountFormDialog> createState() => _BankAccountFormDialogState();
}

class _BankAccountFormDialogState extends State<BankAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bankRepository = BankRepository();
  AccountingRepository? _accountingRepository;

  bool _isLoading = false;
  List<AccountingAccountModel> _accountingAccounts = [];
  List<Bank> _banks = [];

  // Controllers
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  String _currency = 'DOP';
  int? _selectedAccountingAccountId;
  int? _selectedBankId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (_accountingRepository == null) {
        final prefs = await SharedPreferences.getInstance();
        _accountingRepository = AccountingRepository(LocalStorage(prefs));
      }
      final accounts = await _accountingRepository!.getAccounts();
      final banks = await _bankRepository.getBanks();

      setState(() {
        _banks = banks;
        _accountingAccounts = accounts.where((acc) {
          final nameLower = acc.name.toLowerCase();
          return nameLower.contains('banco') ||
              acc.code.startsWith('1101') ||
              acc.code.startsWith('1102');
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _bankRepository.createBankAccount({
        'bank_id': _selectedBankId,
        'name': _nameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'currency': _currency,
        'current_balance': double.tryParse(_balanceController.text) ?? 0.0,
        'accounting_account_id': _selectedAccountingAccountId,
        'is_active': true,
      });

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to signal success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear cuenta: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ModernLoadingOverlay(
        isLoading: _isLoading,
        message: 'Guardando...',
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
                  'Nueva Cuenta Bancaria',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ChurchColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  initialValue: _selectedBankId,
                  decoration: const InputDecoration(
                    labelText: 'Institución Bancaria',
                    border: OutlineInputBorder(),
                  ),
                  items: _banks.map((b) {
                    return DropdownMenuItem(value: b.id, child: Text(b.name));
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedBankId = v);
                  },
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Cuenta',
                    hintText: 'Ej. Banco Popular - Ahorros',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _accountNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Cuenta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'DOP', child: Text('DOP')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _currency = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedAccountingAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta Contable (Enlace)',
                    border: OutlineInputBorder(),
                    helperText:
                        'Selecciona la cuenta del catálogo contable para reportes',
                  ),
                  items: _accountingAccounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text('${acc.code} - ${acc.name}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedAccountingAccountId = v);
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Saldo Inicial',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
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
                      child: const Text('Guardar Cuenta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
