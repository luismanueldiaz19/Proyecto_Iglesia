import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../providers/accounting_provider.dart';
import '../../data/models/accounting_account_model.dart';

class CreateAccountDialog extends ConsumerStatefulWidget {
  const CreateAccountDialog({super.key});

  @override
  ConsumerState<CreateAccountDialog> createState() =>
      _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<CreateAccountDialog> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedType = 'Activo';
  bool _isTransactional = true;

  final List<String> _types = [
    'Activo',
    'Pasivo',
    'Capital',
    'Ingreso',
    'Gasto',
  ];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      setState(() => _error = 'El código y nombre son obligatorios');
      return;
    }

    // Validación Contable (Prefijos por tipo de cuenta)
    if (_selectedType == 'Activo' && !code.startsWith('1')) {
      setState(
        () => _error = 'Las cuentas de Activo deben iniciar con 1 (ej. 1100)',
      );
      return;
    }
    if (_selectedType == 'Pasivo' && !code.startsWith('2')) {
      setState(
        () => _error = 'Las cuentas de Pasivo deben iniciar con 2 (ej. 2100)',
      );
      return;
    }
    if (_selectedType == 'Capital' && !code.startsWith('3')) {
      setState(
        () => _error = 'Las cuentas de Capital deben iniciar con 3 (ej. 3100)',
      );
      return;
    }
    if (_selectedType == 'Ingreso' && !code.startsWith('4')) {
      setState(
        () => _error = 'Las cuentas de Ingreso deben iniciar con 4 (ej. 4100)',
      );
      return;
    }
    if (_selectedType == 'Gasto' && !code.startsWith('5')) {
      setState(
        () => _error = 'Las cuentas de Gasto deben iniciar con 5 (ej. 5100)',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final newAccount = AccountingAccountModel(
      id: 0, // Ignorado por el backend
      code: code,
      name: name,
      type: _selectedType,
      isTransactional: _isTransactional,
    );

    final success = await ref
        .read(accountingProvider.notifier)
        .createAccount(newAccount);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final stateError = ref.read(accountingProvider).error;
      setState(() {
        _isLoading = false;
        _error = stateError ?? 'Error desconocido';
      });
      ref.read(accountingProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva Cuenta Contable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChurchColors.black,
              ),
            ),
            const SizedBox(height: 24),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            CustomTextField(
              controller: _codeController,
              hintText: 'Código (ej. 1103)',
              prefixIcon: Icons.numbers_rounded,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              hintText: 'Nombre de la cuenta (ej. Banco BHD)',
              prefixIcon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: ChurchColors.lightGrey.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.category_rounded,
                  color: ChurchColors.grey,
                ),
              ),
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Es Transaccional (Permite movimientos)'),
              value: _isTransactional,
              activeColor: ChurchColors.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                if (val != null) setState(() => _isTransactional = val);
              },
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: ChurchColors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 160,
                  child: PrimaryButton(
                    onPressed: _isLoading ? null : _onSave,
                    text: 'Guardar',
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
