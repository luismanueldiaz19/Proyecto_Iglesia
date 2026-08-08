import 'package:comunidad_pfantino/core/utils/app_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/presentation/widgets/modern_loading_overlay.dart';
import '../../../../../core/presentation/widgets/page_header.dart';
import '../../../../../core/theme/church_colors.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/bank_transaction_model.dart';
import '../../data/repositories/bank_repository.dart';

class BankReconciliationScreen extends StatefulWidget {
  final int accountId;

  const BankReconciliationScreen({super.key, required this.accountId});

  @override
  State<BankReconciliationScreen> createState() =>
      _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends State<BankReconciliationScreen> {
  final BankRepository _repository = BankRepository();
  bool _isLoading = true;
  BankAccount? _account;
  List<BankTransaction> _pendingTransactions = [];

  // Reconciliation state
  final Set<int> _selectedTransactionIds = {};
  double _statementBalance = 0.0;
  DateTime _statementDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final account = await _repository.getBankAccountDetails(widget.accountId);
      final transactions = await _repository.getTransactionsForAccount(
        widget.accountId,
      );

      setState(() {
        _account = account;
        // Only show pending transactions to reconcile
        _pendingTransactions = transactions
            .where((t) => t.status != 'reconciled')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  double get _clearedBalance {
    double balance = _account?.currentBalance ?? 0; // Book balance
    // Deduct pending transactions that are NOT selected (meaning they are in transit)
    for (var tx in _pendingTransactions) {
      if (!_selectedTransactionIds.contains(tx.id)) {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get _difference => _clearedBalance - _statementBalance;
  bool get _canReconcile => _difference.abs() < 0.01 && _statementBalance > 0;

  Future<void> _completeReconciliation() async {
    if (!_canReconcile) return;

    setState(() => _isLoading = true);
    try {
      // Create reconciliation
      final reconciliation = await _repository.createReconciliation({
        'bank_account_id': widget.accountId,
        'statement_date': _statementDate.toIso8601String(),
        'statement_balance': _statementBalance,
        'notes': 'Conciliación realizada desde la app',
      });

      // Update to completed and attach transactions
      await _repository.updateReconciliation(reconciliation.id, {
        'status': 'completed',
        'transaction_ids': _selectedTransactionIds.toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conciliación completada exitosamente')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/bank/accounts/${widget.accountId}');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al completar conciliación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernLoadingOverlay(
      isLoading: _isLoading,
      message: _account == null ? 'Cargando datos...' : 'Conciliando...',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/bank/accounts/${widget.accountId}');
                      }
                    },
                  ),
                  Expanded(
                    child: PageHeader(
                      title: 'Conciliación Bancaria',
                      subtitle:
                          'Cuenta: ${_account?.name ?? ''} (${_account?.accountNumber ?? ''})',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Transactions List (The Checklist)
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transacciones Pendientes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ChurchColors.primary,
                                ),
                              ),
                              Text(
                                'Marca (✓) las transacciones que aparecen en tu estado de cuenta del banco.',
                                style: TextStyle(color: ChurchColors.grey),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _pendingTransactions.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No hay transacciones pendientes por conciliar.',
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: _pendingTransactions.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final tx =
                                              _pendingTransactions[index];
                                          final isSelected =
                                              _selectedTransactionIds.contains(
                                                tx.id,
                                              );
                                          final isDeposit = tx.amount >= 0;

                                          return CheckboxListTile(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  _selectedTransactionIds.add(
                                                    tx.id,
                                                  );
                                                } else {
                                                  _selectedTransactionIds
                                                      .remove(tx.id);
                                                }
                                              });
                                            },
                                            activeColor: ChurchColors.primary,
                                            title: Text(
                                              tx.description ?? tx.type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${AppFormatters.date.format(tx.date)} • Ref: ${tx.reference ?? 'N/A'}',
                                            ),
                                            secondary: Text(
                                              AppFormatters.currency.format(
                                                tx.amount.abs(),
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDeposit
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Side: Reconciliation Summary and Controls
                    Expanded(flex: 1, child: _buildSummaryPanel()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos del Banco',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChurchColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Saldo Final (según el Banco)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                setState(() {
                  _statementBalance = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _statementDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _statementDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Corte',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppFormatters.date.format(_statementDate)),
                    const Icon(Icons.calendar_today, size: 16),
                  ],
                ),
              ),
            ),
            const Divider(height: 48),
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChurchColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Saldo en Libros', _account?.currentBalance ?? 0),
            _buildSummaryRow('Saldo Conciliado', _clearedBalance),
            _buildSummaryRow('Saldo Banco', _statementBalance),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _difference.abs() < 0.01
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _difference.abs() < 0.01 ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _difference.abs() < 0.01
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppFormatters.currency.format(_difference),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _difference.abs() < 0.01
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canReconcile ? _completeReconciliation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChurchColors.primary,
                  foregroundColor: ChurchColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'Completar Conciliación',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (!_canReconcile && _statementBalance > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'La diferencia debe ser \$0.00 para completar.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ChurchColors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                AppFormatters.currency.format(amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
