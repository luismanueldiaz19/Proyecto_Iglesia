import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/cash_provider.dart';

class CashierDashboardScreen extends ConsumerWidget {
  const CashierDashboardScreen({super.key});

  Future<void> _openTemplatePdf(
    BuildContext context,
    WidgetRef ref,
    String moduleName,
  ) async {
    try {
      final repo = ref.read(cashRepositoryProvider);
      final token = ref.read(authProvider.notifier).getToken();

      if (token == null) throw Exception('No autenticado');

      final url = await repo.getTemplatePdfUrl(token);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir el enlace de la plantilla.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir la plantilla PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashProvider);
    final notifier = ref.read(cashProvider.notifier);

    return Scaffold(
      backgroundColor: ChurchColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cajero (Cuadre)',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ChurchColors.black,
                  ),
                ),
                if (state.modules.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ChurchColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ChurchColors.lightGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: state.selectedModule?.id,
                            hint: const Text('Seleccionar Módulo'),
                            items: state.modules.map((m) {
                              return DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final m = state.modules.firstWhere(
                                  (x) => x.id == val,
                                );
                                notifier.selectModule(m);
                              }
                            },
                          ),
                        ),
                      ),
                      if (state.selectedModule != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Imprimir Plantilla',
                          color: ChurchColors.primary,
                          onPressed: () => _openTemplatePdf(
                            context,
                            ref,
                            state.selectedModule!.name,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apertura, movimientos manuales y cierre de caja',
                  style: TextStyle(fontSize: 16, color: ChurchColors.grey),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Ver Historial de Cuadres'),
                  onPressed: () {
                    if (state.selectedModule != null) {
                      context.push('/cashier/history');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona un módulo primero'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Volver / Descartar Error'),
                        onPressed: () {
                          notifier.clearError();
                        },
                      ),
                    ],
                  ),
                ),
              )
            else if (state.selectedModule == null)
              const Expanded(
                child: Center(
                  child: Text('No hay módulos de caja configurados.'),
                ),
              )
            else if (state.activeReconciliation == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.point_of_sale_rounded,
                        size: 80,
                        color: ChurchColors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'La caja de ${state.selectedModule!.name} está cerrada',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Debes abrir el turno para empezar a recibir transacciones.',
                        style: TextStyle(color: ChurchColors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('Abrir Turno de Caja'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ChurchColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () async {
                          final now = DateTime.now();
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(2020),
                            lastDate: now,
                            helpText: 'SELECCIONA LA FECHA DE APERTURA',
                            cancelText: 'CANCELAR',
                            confirmText: 'ABRIR CAJA',
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: ChurchColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (selectedDate != null) {
                            notifier.openReconciliation(date: selectedDate);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              // Turno abierto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ChurchColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Turno Abierto',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Caja: ${state.selectedModule!.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Fecha: ${state.activeReconciliation!.date}',
                                style: const TextStyle(
                                  color: ChurchColors.grey,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ChurchColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(
                                  Icons.calculate_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Cuadrar y Cerrar Caja',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  context.push('/cashier/reconciliation');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Movimientos del Turno',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.activeReconciliation!.transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay transacciones en este turno.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: state
                                  .activeReconciliation!
                                  .transactions
                                  .length,
                              itemBuilder: (context, index) {
                                final tx = state
                                    .activeReconciliation!
                                    .transactions[index];
                                final isIncome = tx.type == 'income';
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: isIncome
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      child: Icon(
                                        isIncome
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      tx.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Cuenta ID: ${tx.accountId}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ChurchColors.grey,
                                      ),
                                    ),
                                    trailing: Text(
                                      '${isIncome ? '+' : '-'} RD\$${CurrencyFormatter.formatAmount(tx.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
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

// class _AddTransactionDialog extends StatefulWidget {
//   final CashNotifier notifier;
//   final String transactionType; // 'income' or 'expense'
//   const _AddTransactionDialog({
//     required this.notifier,
//     required this.transactionType,
//   });

//   @override
//   State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
// }

// class _AddTransactionDialogState extends State<_AddTransactionDialog> {
//   final _amountCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _rateCtrl = TextEditingController();

//   String _selectedCurrency = 'DOP';

//   @override
//   void initState() {
//     super.initState();
//     _rateCtrl.text = '1.0';
//   }

//   void _onCurrencyChanged(String? newValue) {
//     if (newValue == null) return;
//     setState(() {
//       _selectedCurrency = newValue;
//       if (newValue == 'USD') {
//         _rateCtrl.text = '58.0';
//       } else if (newValue == 'EUR') {
//         _rateCtrl.text = '65.0';
//       } else {
//         _rateCtrl.text = '1.0';
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIncome = widget.transactionType == 'income';

//     return AlertDialog(
//       title: Text(isIncome ? 'Registrar Ingreso' : 'Registrar Gasto'),
//       content: SizedBox(
//         width: 400,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomDropdownField<String>(
//               value: _selectedCurrency,
//               labelText: 'Moneda',
//               items: const [
//                 DropdownMenuItem(
//                   value: 'DOP',
//                   child: Text('Pesos Dominicanos (DOP)'),
//                 ),
//                 DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
//                 DropdownMenuItem(value: 'EUR', child: Text('Euros (EUR)')),
//               ],
//               onChanged: _onCurrencyChanged,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: CustomTextField(
//                     controller: _amountCtrl,
//                     labelText: 'Monto Original',
//                     prefixText: _selectedCurrency == 'DOP'
//                         ? 'RD\$ '
//                         : (_selectedCurrency == 'USD' ? 'US\$ ' : '€ '),
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                   ),
//                 ),
//                 if (_selectedCurrency != 'DOP') ...[
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 1,
//                     child: CustomTextField(
//                       controller: _rateCtrl,
//                       labelText: 'Tasa',
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 16),
//             CustomTextField(
//               controller: _descCtrl,
//               labelText: 'Descripción / Concepto',
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text(
//             'Cancelar',
//             style: TextStyle(color: ChurchColors.grey),
//           ),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: isIncome ? ChurchColors.primary : Colors.red,
//             foregroundColor: Colors.white,
//           ),
//           onPressed: () {
//             final rawAmount = double.tryParse(_amountCtrl.text) ?? 0.0;
//             final rate = double.tryParse(_rateCtrl.text) ?? 1.0;

//             if (rawAmount > 0 && _descCtrl.text.isNotEmpty) {
//               double finalAmount = rawAmount;
//               String finalDesc = _descCtrl.text;

//               if (_selectedCurrency != 'DOP') {
//                 finalAmount = rawAmount * rate;
//                 final symbol = _selectedCurrency == 'USD' ? 'US\$' : '€';
//                 finalDesc =
//                     '[$symbol${rawAmount.toStringAsFixed(2)} @ $rate] $finalDesc';
//               }

//               // ID 15 para Ingresos, ID 16 para Gastos (ejemplo genérico)
//               final accountId = isIncome ? 15 : 16;

//               widget.notifier.addTransaction(
//                 accountId,
//                 finalAmount,
//                 widget.transactionType,
//                 finalDesc,
//               );
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Guardar'),
//         ),
//       ],
//     );
//   }
// }
