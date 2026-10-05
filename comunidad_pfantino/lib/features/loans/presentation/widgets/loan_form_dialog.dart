import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../providers/loan_provider.dart';
import '../../data/models/loan_model.dart';
import '../../../../core/theme/church_colors.dart';

class LoanFormDialog extends ConsumerStatefulWidget {
  final LoanModel? loan;

  const LoanFormDialog({super.key, this.loan});

  @override
  ConsumerState<LoanFormDialog> createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends ConsumerState<LoanFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _lenderNameController = TextEditingController();
  final _loanNumberController = TextEditingController();
  final _memberNumberController = TextEditingController();
  final _debtorNameController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  final _monthlyRateController = TextEditingController();
  final _termMonthsController = TextEditingController();
  final _installmentAmountController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      final l = widget.loan!;
      _lenderNameController.text = l.lenderName;
      _loanNumberController.text = l.loanNumber;
      _memberNumberController.text = l.memberNumber ?? '';
      _debtorNameController.text = l.debtorName ?? '';
      _originalAmountController.text = l.originalAmount.toStringAsFixed(2);
      _currentBalanceController.text = l.currentBalance.toStringAsFixed(2);
      _monthlyRateController.text = l.monthlyRate.toStringAsFixed(2);
      _termMonthsController.text = l.termMonths.toString();
      _installmentAmountController.text = l.installmentAmount.toStringAsFixed(
        2,
      );
      _startDate = l.startDate;
      _dueDate = l.dueDate;
    }
  }

  @override
  void dispose() {
    _lenderNameController.dispose();
    _loanNumberController.dispose();
    _memberNumberController.dispose();
    _debtorNameController.dispose();
    _originalAmountController.dispose();
    _currentBalanceController.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: ChurchColors.primary),
          ),
          child: child!,
        );
      },
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
          _currentBalanceController.text.isEmpty
              ? _originalAmountController.text.replaceAll(',', '')
              : _currentBalanceController.text.replaceAll(',', ''),
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

      if (widget.loan != null) {
        await ref
            .read(loanProvider.notifier)
            .updateLoan(widget.loan!.id!, loan);
      } else {
        await ref.read(loanProvider.notifier).createLoan(loan);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.loan != null
                  ? 'Préstamo actualizado exitosamente'
                  : 'Préstamo registrado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Retorna true al crearlo/editarlo exitosamente
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
    // Usamos MediaQuery para adaptar a movil/escritorio
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isDesktop ? 600 : screenWidth * 0.9,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.loan != null
                        ? 'Editar Préstamo'
                        : 'Registrar Préstamo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ChurchColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos del Prestamista / Socio',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ChurchColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _lenderNameController,
                        labelText: 'Nombre Prestamista',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _loanNumberController,
                              labelText: 'Número de Préstamo',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _memberNumberController,
                              labelText: 'Número de Socio',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _debtorNameController,
                        labelText: 'Nombre del Deudor (Opcional)',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Condiciones Financieras',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ChurchColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _originalAmountController,
                              labelText: 'Monto Original',
                              prefixText: '\$ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _currentBalanceController,
                              labelText: 'Balance Actual',
                              prefixText: '\$ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _monthlyRateController,
                              labelText: 'Tasa Mensual',
                              suffixText: '%',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _termMonthsController,
                              labelText: 'Plazo (Meses)',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _installmentAmountController,
                              labelText: 'Cuota Regular',
                              prefixText: '\$ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Préstamo',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_startDate),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: ChurchColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Vencimiento (Opcional)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dueDate != null
                                          ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(_dueDate!)
                                          : 'Seleccionar',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: ChurchColors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: ChurchColors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    width: 160,
                    text: 'Guardar',
                    isLoading: _isLoading,
                    onPressed: _submit,
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
