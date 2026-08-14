import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/church_confirm_dialog.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/cash_provider.dart';
import '../../data/models/denomination_model.dart';

class CashReconciliationScreen extends ConsumerStatefulWidget {
  const CashReconciliationScreen({super.key});

  @override
  ConsumerState<CashReconciliationScreen> createState() =>
      _CashReconciliationScreenState();
}

class _CashReconciliationScreenState
    extends ConsumerState<CashReconciliationScreen> {
  // Mapa de denomination.id a quantity
  final Map<int, int> quantities = {};

  double usdRate = 58.0;
  double eurRate = 65.0;

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Inicializar cantidades en 0
    final state = ref.read(cashProvider);
    for (var d in state.denominations) {
      quantities[d.id] = 0;
    }
  }

  Future<void> _openTemplatePdf() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir la plantilla PDF: $e')),
        );
      }
    }
  }

  double _calculateTotal(List<DenominationModel> denoms) {
    double total = 0;
    for (var d in denoms) {
      final q = quantities[d.id] ?? 0;
      double rowTotal = d.value * q;
      if (d.currency == 'USD') rowTotal *= usdRate;
      if (d.currency == 'EUR') rowTotal *= eurRate;
      total += rowTotal;
    }
    return total;
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return 'US\$';
      case 'DOP':
        return 'RD\$';
      default:
        return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashProvider);
    final active = state.activeReconciliation;

    if (active == null) {
      return const Scaffold(
        body: Center(child: Text('No hay caja activa para cuadrar')),
      );
    }

    final theoreticalIncome = active.transactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final theoreticalExpense = active.transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final theoreticalTotal =
        theoreticalIncome - theoreticalExpense; // Saldo esperado

    final physicalTotal = _calculateTotal(state.denominations);
    final difference = physicalTotal - theoreticalTotal;

    final isSobrante = difference > 0;
    final isFaltante = difference < 0;
    final isPerfect = difference == 0;

    return Scaffold(
      // backgroundColor: ChurchColors.background,
      appBar: AppBar(
        title: const Text('Cuadre de Caja'),
        backgroundColor: ChurchColors.white,
        foregroundColor: ChurchColors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir Plantilla en Blanco',
            onPressed: _openTemplatePdf,
          ),
        ],
      ),
      body: Row(
        children: [
          // Izquierda: Formulario de Billetes y Monedas
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: ChurchColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desglose de Billetes y Monedas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: usdRate.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Tasa USD',
                            prefixText: 'RD\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) {
                            setState(() {
                              usdRate = double.tryParse(val) ?? 58.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: eurRate.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Tasa EUR',
                            prefixText: 'RD\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) {
                            setState(() {
                              eurRate = double.tryParse(val) ?? 65.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final groupedDenominations =
                            <String, List<DenominationModel>>{};
                        for (var d in state.denominations) {
                          groupedDenominations
                              .putIfAbsent(d.currency, () => [])
                              .add(d);
                        }
                        final currencyOrder = ['DOP', 'USD', 'EUR'];
                        final sortedEntries =
                            groupedDenominations.entries.toList()..sort((a, b) {
                              final indexA = currencyOrder.indexOf(a.key);
                              final indexB = currencyOrder.indexOf(b.key);
                              final weightA = indexA == -1 ? 999 : indexA;
                              final weightB = indexB == -1 ? 999 : indexB;
                              return weightA.compareTo(weightB);
                            });

                        return ListView(
                          children: sortedEntries.map((entry) {
                            final currency = entry.key;
                            final denoms = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    currency,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ChurchColors.grey,
                                    ),
                                  ),
                                ),
                                ...denoms.map((d) {
                                  final q = quantities[d.id] ?? 0;
                                  final rawTotal = q * d.value;
                                  double convertedTotal = rawTotal;
                                  if (d.currency == 'USD') {
                                    convertedTotal *= usdRate;
                                  }
                                  if (d.currency == 'EUR') {
                                    convertedTotal *= eurRate;
                                  }

                                  final symbol = _getCurrencySymbol(d.currency);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            d.type == 'bill'
                                                ? Icons.money
                                                : Icons.monetization_on,
                                            color: ChurchColors.primary,
                                          ),
                                          const SizedBox(width: 16),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              '$symbol${d.value.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          _DenominationCounter(
                                            initialValue: q,
                                            onChanged: (newVal) {
                                              setState(() {
                                                quantities[d.id] = newVal;
                                              });
                                            },
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: 140,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '= $symbol${rawTotal.toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: ChurchColors.primary,
                                                  ),
                                                ),
                                                if (d.currency != 'DOP')
                                                  Text(
                                                    'RD\$${convertedTotal.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ChurchColors.grey,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Derecha: Resumen y Cierre
          Expanded(
            flex: 1,
            child: Container(
              color: ChurchColors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Turno',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  _buildSummaryRow(
                    'Ingresos Registrados',
                    theoreticalIncome,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Gastos Registrados',
                    theoreticalExpense,
                    Colors.red,
                  ),
                  const Divider(height: 32),

                  _buildSummaryRow(
                    'Saldo Esperado en Caja',
                    theoreticalTotal,
                    ChurchColors.black,
                    isBold: true,
                  ),
                  const SizedBox(height: 24),

                  _buildSummaryRow(
                    'Efectivo Físico Contado',
                    physicalTotal,
                    ChurchColors.primary,
                    isBold: true,
                  ),
                  const SizedBox(height: 32),

                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: isPerfect
                  //         ? Colors.green.withValues(alpha: 0.1)
                  //         : (isFaltante
                  //               ? Colors.red.withValues(alpha: 0.1)
                  //               : Colors.orange.withValues(alpha: 0.1)),
                  //     borderRadius: BorderRadius.circular(8),
                  //     border: Border.all(
                  //       color: isPerfect
                  //           ? Colors.green
                  //           : (isFaltante ? Colors.red : Colors.orange),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       Text(
                  //         isPerfect
                  //             ? 'CUADRE PERFECTO'
                  //             : (isFaltante
                  //                   ? 'FALTANTE DE CAJA'
                  //                   : 'SOBRANTE DE CAJA'),
                  //         textAlign: TextAlign.center,
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 18,
                  //           color: isPerfect
                  //               ? Colors.green
                  //               : (isFaltante ? Colors.red : Colors.orange),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         '\$${difference.abs().toStringAsFixed(2)}',
                  //         textAlign: TextAlign.center,
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 32,
                  //           color: isPerfect
                  //               ? Colors.green
                  //               : (isFaltante ? Colors.red : Colors.orange),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const Spacer(),
                  CustomTextField(
                    controller: _notesController,
                    labelText: 'Notas u Observaciones (Opcional)',
                    hintText: 'Ej. Faltante por compra de botellón de agua...',
                  ),
                  const SizedBox(height: 16),

                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFaltante
                              ? Colors.red
                              : ChurchColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final confirm = await showChurchConfirmDialog(
                            context: context,
                            title: 'Confirmar Cierre de Caja',
                            content: isPerfect
                                ? 'El cuadre es perfecto. ¿Deseas cerrar la caja?'
                                : 'Hay una diferencia de \$${difference.abs().toStringAsFixed(2)}. Esto generará un asiento contable automático. ¿Deseas continuar?',
                            cancelText: 'Revisar',
                            confirmText: 'Cerrar Definitivamente',
                          );

                          if (confirm == true) {
                            // Preparar payload
                            List<Map<String, dynamic>> payloadDenoms = [];
                            quantities.forEach((id, q) {
                              if (q > 0) {
                                final d = state.denominations.firstWhere(
                                  (x) => x.id == id,
                                );
                                double convertedTotal = q * d.value;
                                if (d.currency == 'USD')
                                  convertedTotal *= usdRate;
                                if (d.currency == 'EUR')
                                  convertedTotal *= eurRate;

                                payloadDenoms.add({
                                  'id': id,
                                  'quantity': q,
                                  'total': convertedTotal,
                                });
                              }
                            });

                            await ref
                                .read(cashProvider.notifier)
                                .closeReconciliation(
                                  payloadDenoms,
                                  physicalTotal,
                                  notes: _notesController.text.trim().isNotEmpty
                                      ? _notesController.text.trim()
                                      : null,
                                );
                            if (context.mounted) {
                              context.pop(); // Volver al dashboard
                            }
                          }
                        },
                        child: const Text(
                          'CONFIRMAR Y CERRAR CAJA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'RD\$${CurrencyFormatter.formatAmount(amount)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DenominationCounter extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _DenominationCounter({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_DenominationCounter> createState() => _DenominationCounterState();
}

class _DenominationCounterState extends State<_DenominationCounter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0 ? '' : widget.initialValue.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _DenominationCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      final textVal = int.tryParse(_controller.text) ?? 0;
      if (textVal != widget.initialValue) {
        final newText = widget.initialValue == 0
            ? ''
            : widget.initialValue.toString();
        _controller.value = _controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: widget.initialValue > 0
              ? () {
                  widget.onChanged(widget.initialValue - 1);
                }
              : null,
        ),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              final newVal = int.tryParse(val) ?? 0;
              widget.onChanged(newVal);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            widget.onChanged(widget.initialValue + 1);
          },
        ),
      ],
    );
  }
}
