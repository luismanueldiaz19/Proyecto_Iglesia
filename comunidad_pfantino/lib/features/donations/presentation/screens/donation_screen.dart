import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/donation_provider.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorCedulaController = TextEditingController();
  final _donorRncController = TextEditingController();
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  bool _withReceipt = false;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '###-###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  String _paymentMethod = 'Efectivo';

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _donorCedulaController.dispose();
    _donorRncController.dispose();
    _conceptController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final donationId = await ref
        .read(donationProvider.notifier)
        .createDonation(
          donorName: _donorNameController.text.trim(),
          donorPhone: _donorPhoneController.text.trim(),
          donorCedula: _donorCedulaController.text.trim(),
          donorRnc: _donorRncController.text.trim(),
          withReceipt: _withReceipt,
          paymentMethod: _paymentMethod,
          concept: _conceptController.text.trim(),
          amount: double.tryParse(_amountController.text) ?? 0,
          date: _selectedDate,
        );

    print(donationId);
    if (donationId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Donación registrada exitosamente. Generando recibo...',
          ),
        ),
      );

      final currentDonorName = _donorNameController.text.trim();

      // Limpiar formulario
      _donorNameController.clear();
      _donorPhoneController.clear();
      _donorCedulaController.clear();
      _donorRncController.clear();
      _conceptController.clear();
      _amountController.clear();
      setState(() {
        _withReceipt = false;
        _paymentMethod = 'Efectivo';
        _selectedDate = null;
      });

      // Descargar PDF
      final pdfUrl = await ref
          .read(donationProvider.notifier)
          .getPdfUrl(donationId);
      if (pdfUrl != null && mounted) {
        await _downloadPdf(pdfUrl, currentDonorName);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar la donación')),
      );
    }
  }

  Future<void> _downloadPdf(String url, String donorName) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir el enlace del recibo.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir el PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(donationProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibir Donación'),
        backgroundColor: ChurchColors.white,
        foregroundColor: ChurchColors.black,
      ),
      backgroundColor: ChurchColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Información de la Donación',
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
                          child: TextFormField(
                            controller: _donorNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Donante *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Campo requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _donorPhoneController,
                            inputFormatters: [_phoneFormatter],
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              hintText: '809-000-0000',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _donorCedulaController,
                            decoration: const InputDecoration(
                              labelText: 'Cédula',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _donorRncController,
                            decoration: const InputDecoration(
                              labelText: 'RNC',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _conceptController,
                            decoration: const InputDecoration(
                              labelText: 'Concepto de la Donación *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Campo requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Donación',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedDate == null
                                    ? 'Hoy (Por defecto)'
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Monto *',
                              border: OutlineInputBorder(),
                              prefixText: 'RD\$ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v!.isEmpty) return 'Campo requerido';
                              if (double.tryParse(v) == null) {
                                return 'Monto inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _paymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Método de Pago',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Efectivo',
                                child: Text('Efectivo'),
                              ),
                              DropdownMenuItem(
                                value: 'Transferencia',
                                child: Text('Transferencia'),
                              ),
                              DropdownMenuItem(
                                value: 'Cheque',
                                child: Text('Cheque'),
                              ),
                              DropdownMenuItem(
                                value: 'Tarjeta',
                                child: Text('Tarjeta'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Con Comprobante Fiscal'),
                            value: _withReceipt,
                            onChanged: (v) =>
                                setState(() => _withReceipt = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ChurchColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.print),
                        label: const Text(
                          'Registrar e Imprimir Recibo',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
