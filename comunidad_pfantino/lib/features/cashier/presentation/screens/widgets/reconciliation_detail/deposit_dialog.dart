import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/network/api_config.dart';
import '../../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../../core/theme/church_colors.dart';
import '../../../../../accounting/providers/accounting_provider.dart';
import '../../../controllers/cash_reconciliation_detail_controller.dart';

class DepositDialog extends ConsumerStatefulWidget {
  final int reconciliationId;
  final double initialAmount;

  const DepositDialog({
    super.key,
    required this.reconciliationId,
    required this.initialAmount,
  });

  @override
  ConsumerState<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends ConsumerState<DepositDialog> {
  late final TextEditingController _amountCtrl;

  // Cuenta contable (para el asiento)
  int? _selectedAccountId;

  // Cuenta del módulo de bancos (para BankTransaction + IngresoProvicional)
  int? _selectedBankAccountId;
  List<dynamic> _bankAccounts = [];
  bool _isLoadingBanks = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(2),
    );

    Future.microtask(() {
      if (ref.read(accountingProvider).accounts.isEmpty) {
        ref.read(accountingProvider.notifier).loadAccounts();
      }
    });

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
        if (mounted) setState(() => _bankAccounts = data);
      }
    } catch (e) {
      debugPrint('Error cargando cuentas bancarias: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedAccountId != null &&
      _selectedBankAccountId != null &&
      !_isSubmitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final depositAmount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (depositAmount <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(
            cashReconciliationDetailProvider(widget.reconciliationId).notifier,
          )
          .executeDeposit(_selectedAccountId!, _selectedBankAccountId!, depositAmount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Depósito registrado correctamente.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountingState = ref.watch(accountingProvider);
    // Cuentas contables de banco (código 1102*)
    final accountingBankAccounts = accountingState.accounts
        .where(
          (a) =>
              (a.type == 'Activo' || a.type == 'asset') &&
              a.isTransactional &&
              a.code.startsWith('1102'),
        )
        .toList();

    bool showAccountingField = true;
    if (_selectedBankAccountId != null) {
      final selectedAccount = _bankAccounts.firstWhere(
        (a) => a['id'] == _selectedBankAccountId,
        orElse: () => null,
      );
      if (selectedAccount != null &&
          selectedAccount['accounting_account_id'] != null) {
        final accId = int.tryParse(selectedAccount['accounting_account_id'].toString());
        if (accId != null && accountingBankAccounts.any((a) => a.id == accId)) {
          showAccountingField = false;
        }
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Encabezado ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar Depósito',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'El depósito se registrará en el módulo de bancos',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ChurchColors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // ── Monto ────────────────────────────────────────────────────
            _FieldLabel(label: 'Monto a depositar'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: 'RD\$ ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Cuenta del módulo de bancos ──────────────────────────────
            _FieldLabel(label: 'Cuenta de banco (módulo de bancos)'),
            const SizedBox(height: 8),
            _isLoadingBanks
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Banco destino del depósito',
                      prefixIcon: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF2E7D32),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    value: _selectedBankAccountId,
                    items: _bankAccounts.map((account) {
                      final bankName = account['bank'] != null
                          ? account['bank']['name']
                          : 'Banco';
                      final accNum = account['account_number'] ?? '';
                      final suffix = accNum.toString().isNotEmpty
                          ? ' ($accNum)'
                          : '';
                      return DropdownMenuItem<int>(
                        value: account['id'],
                        child: Text(
                          '$bankName$suffix',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBankAccountId = val;
                        final selectedAccount = _bankAccounts.firstWhere(
                          (a) => a['id'] == val,
                          orElse: () => null,
                        );
                        if (selectedAccount != null &&
                            selectedAccount['accounting_account_id'] != null) {
                          final accId = int.tryParse(selectedAccount['accounting_account_id'].toString());
                          if (accId != null && accountingBankAccounts.any((a) => a.id == accId)) {
                            _selectedAccountId = accId;
                          }
                        }
                      });
                    },
                  ),

            if (showAccountingField) ...[
              const SizedBox(height: 16),

              // ── Cuenta contable del banco (para asiento) ─────────────────
              _FieldLabel(label: 'Cuenta contable de banco'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Cuenta contable (1102-...)',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                value: _selectedAccountId,
                items: accountingBankAccounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text(
                      '${a.code} - ${a.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
            ],

            const SizedBox(height: 28),

            // ── Botones ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  text: 'Confirmar Depósito',
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF2E7D32),
                  width: null,
                  isLoading: _isSubmitting,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFF444444),
      ),
    );
  }
}
