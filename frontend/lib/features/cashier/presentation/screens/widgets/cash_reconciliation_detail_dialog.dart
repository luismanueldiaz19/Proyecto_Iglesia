import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/church_colors.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../accounting/providers/accounting_provider.dart';
import '../../../data/models/cash_reconciliation_model.dart';
import '../../../providers/cash_provider.dart';

class CashReconciliationDetailDialog extends ConsumerStatefulWidget {
  final int reconciliationId;

  const CashReconciliationDetailDialog({
    super.key,
    required this.reconciliationId,
  });

  @override
  ConsumerState<CashReconciliationDetailDialog> createState() =>
      _CashReconciliationDetailDialogState();
}

class _CashReconciliationDetailDialogState
    extends ConsumerState<CashReconciliationDetailDialog> {
  bool _isLoading = true;
  String? _error;
  CashReconciliationModel? _reconciliation;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final repo = ref.read(cashRepositoryProvider);
      final token = await ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final details = await repo.getReconciliationDetails(
        token,
        widget.reconciliationId,
      );

      if (mounted) {
        setState(() {
          _reconciliation = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openPdf() async {
    try {
      final repo = ref.read(cashRepositoryProvider);
      final token = await ref.read(authProvider.notifier).getToken();
      if (token == null) throw Exception('No autenticado');

      final url = await repo.getPdfUrl(token, widget.reconciliationId);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir el PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    }
  }

  void _showDepositDialog() {
    int? selectedAccountId;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final accountingState = ref.watch(accountingProvider);
            // Filtrar cuentas de tipo 'asset' o similares para bancos.
            final bankAccounts = accountingState.accounts
                .where((a) => a.type == 'asset')
                .toList();

            return AlertDialog(
              title: const Text('Realizar Depósito Bancario'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto a depositar: \$${_reconciliation!.totalGeneral.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Seleccione la cuenta bancaria de destino:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cuenta de Banco',
                      ),
                      value: selectedAccountId,
                      items: bankAccounts.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.code} - ${a.name}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedAccountId = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedAccountId == null
                      ? null
                      : () async {
                          Navigator.pop(context); // Cierra el modal de depósito
                          await _executeDeposit(selectedAccountId!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmar Depósito'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeDeposit(int bankAccountId) async {
    try {
      await ref
          .read(cashProvider.notifier)
          .depositCash(widget.reconciliationId, bankAccountId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depósito registrado correctamente.')),
        );
        Navigator.pop(context); // Cierra el detalle
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Detalle de Cuadre #${widget.reconciliationId}'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : _reconciliation == null
            ? const Center(child: Text('No se encontraron detalles'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ChurchColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha',
                                style: TextStyle(color: ChurchColors.grey),
                              ),
                              Text(
                                _reconciliation!.date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Diferencia',
                                style: TextStyle(color: ChurchColors.grey),
                              ),
                              Text(
                                '\$${_reconciliation!.difference.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _reconciliation!.difference == 0
                                      ? Colors.green
                                      : _reconciliation!.difference < 0
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Transacciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _reconciliation!.transactions.isEmpty
                        ? const Text('No hay transacciones')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reconciliation!.transactions.length,
                            itemBuilder: (context, index) {
                              final tx = _reconciliation!.transactions[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  tx.type == 'income'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: tx.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(tx.description),
                                trailing: Text(
                                  '\$${tx.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      'Desglose Físico (Billetes y Monedas)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _reconciliation!.denominations.isEmpty
                        ? const Text('No hay desglose registrado')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reconciliation!.denominations.length,
                            itemBuilder: (context, index) {
                              final den = _reconciliation!.denominations[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.money,
                                  color: ChurchColors.primary,
                                ),
                                title: Text(
                                  '${den.denomination.currency} - ${den.denomination.value.toStringAsFixed(0)}',
                                ),
                                subtitle: Text('Cantidad: ${den.quantity}'),
                                trailing: Text(
                                  '\$${den.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      'Resumen General',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Gastos:'),
                        Text(
                          '\$${_reconciliation!.totalExpenses.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Efectivo Físico Contado:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${_reconciliation!.totalGeneral.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        if (!_isLoading &&
            _error == null &&
            _reconciliation != null &&
            !_reconciliation!.isDeposited &&
            _reconciliation!.totalGeneral > 0)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.account_balance),
            label: const Text('Registrar Depósito Bancario'),
            onPressed: _showDepositDialog,
          ),
        if (!_isLoading && _error == null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ChurchColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generar / Imprimir PDF'),
            onPressed: _openPdf,
          ),
      ],
    );
  }
}
