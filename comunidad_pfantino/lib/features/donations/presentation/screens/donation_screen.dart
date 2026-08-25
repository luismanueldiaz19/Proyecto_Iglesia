import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
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
                          child: CustomTextField(
                            controller: _donorNameController,
                            labelText: 'Nombre del Donante *',
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Campo requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _donorPhoneController,
                            inputFormatters: [_phoneFormatter],
                            keyboardType: TextInputType.phone,
                            labelText: 'Teléfono',
                            hintText: '809-000-0000',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _donorCedulaController,
                            labelText: 'Cédula',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _donorRncController,
                            labelText: 'RNC',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _conceptController,
                            labelText: 'Concepto de la Donación *',
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Campo requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                            controller: TextEditingController(
                              text: _selectedDate == null
                                  ? 'Hoy (Por defecto)'
                                  : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                            ),
                            labelText: 'Fecha de Donación',
                            readOnly: true,
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
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                            controller: _amountController,
                            labelText: 'Monto *',
                            prefixText: 'RD\$ ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Campo requerido';
                              }
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
                          child: CustomDropdownField<String>(
                            value: _paymentMethod,
                            labelText: 'Método de Pago',
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
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _paymentMethod = v);
                              }
                            },
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
                    PrimaryButton(
                      onPressed: isLoading ? null : _submit,
                      text: 'Registrar e Imprimir Recibo',
                      isLoading: isLoading,
                      icon: Icons.print,
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
