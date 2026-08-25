import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/accounting_engine_config_provider.dart';
import '../../providers/accounting_provider.dart';
import '../../data/models/accounting_engine_config_model.dart';

class CreateOperationConfigDialog extends ConsumerStatefulWidget {
  const CreateOperationConfigDialog({super.key});

  @override
  ConsumerState<CreateOperationConfigDialog> createState() =>
      _CreateOperationConfigDialogState();
}

class _CreateOperationConfigDialogState
    extends ConsumerState<CreateOperationConfigDialog> {
  final _formKey = GlobalKey<FormState>();

  String _operationCode = '';
  String _name = '';
  int? _debitAccountId;
  int? _creditAccountId;
  int? _taxAccountId;
  double _taxPercentage = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Asegurarse de que las cuentas estén cargadas para los dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(accountingProvider).accounts.isEmpty) {
        ref.read(accountingProvider.notifier).loadAccounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountingState = ref.watch(accountingProvider);
    final allAccounts = accountingState.accounts;

    return AlertDialog(
      title: const Text('Nueva Configuración de Operación'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Código de Operación (Ej. VENTA, DONACION)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => _operationCode = value!.toUpperCase(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Operación',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Cuenta de Débito (Aumenta Activos/Gastos)',
                    border: OutlineInputBorder(),
                  ),
                  items: allAccounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.code} - ${a.name}'),
                        ),
                      )
                      .toList(),
                  validator: (value) => value == null ? 'Requerido' : null,
                  onChanged: (value) => setState(() => _debitAccountId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Cuenta de Crédito (Aumenta Pasivos/Ingresos)',
                    border: OutlineInputBorder(),
                  ),
                  items: allAccounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.code} - ${a.name}'),
                        ),
                      )
                      .toList(),
                  validator: (value) => value == null ? 'Requerido' : null,
                  onChanged: (value) =>
                      setState(() => _creditAccountId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Cuenta de Impuestos (ITBIS) - Opcional',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _taxAccountId,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Sin Impuestos'),
                    ),
                    ...allAccounts.map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.code} - ${a.name}'),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _taxAccountId = value),
                ),
                if (_taxAccountId != null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Porcentaje de Impuesto (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    initialValue: '18.00',
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                        ? 'Inválido'
                        : null,
                    onSaved: (value) => _taxPercentage = double.parse(value!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: ChurchColors.primary,
            foregroundColor: ChurchColors.white,
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
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final newConfig = AccountingEngineConfigModel(
      id: 0,
      operationCode: _operationCode,
      name: _name,
      debitAccountId: _debitAccountId!,
      creditAccountId: _creditAccountId!,
      taxAccountId: _taxAccountId,
      taxPercentage: _taxAccountId != null ? _taxPercentage : 0.0,
    );

    final success = await ref
        .read(accountingEngineConfigProvider.notifier)
        .createConfig(newConfig);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(accountingEngineConfigProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al guardar'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(accountingEngineConfigProvider.notifier).clearError();
      }
    }
  }
}
