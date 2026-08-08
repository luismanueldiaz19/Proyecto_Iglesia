import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/accounting_engine_config_provider.dart';
import '../widgets/create_operation_config_dialog.dart';

class AccountingOperationsScreen extends ConsumerWidget {
  const AccountingOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountingEngineConfigProvider);
    final user = ref.read(authProvider.notifier).currentUser;
    final isAdmin = user?.role == 'admin' || user?.role == 'Administrador';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuración de Operaciones',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: ChurchColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Administra cómo se registran las transacciones automáticamente en el motor contable',
                        style: TextStyle(color: ChurchColors.grey),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const CreateOperationConfigDialog(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nueva Operación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChurchColors.primary,
                      foregroundColor: ChurchColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Contenido Principal (Tabla)
            Expanded(
              child: Container(
                width: double.infinity,
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
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref
                                  .read(accountingEngineConfigProvider.notifier)
                                  .loadConfigs(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  ChurchColors.lightGrey.withValues(alpha: 0.3),
                                ),
                                columns: [
                                  const DataColumn(
                                    label: Text(
                                      'Código',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Cuenta Débito',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Cuenta Crédito',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Impuesto (ITBIS)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isAdmin)
                                    const DataColumn(
                                      label: Text(
                                        'Acciones',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                                rows: state.configs.map((config) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          config.operationCode,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(config.name)),
                                      DataCell(
                                        Text(
                                          '${config.debitAccount?.code ?? ""} - ${config.debitAccount?.name ?? ""}',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${config.creditAccount?.code ?? ""} - ${config.creditAccount?.name ?? ""}',
                                        ),
                                      ),
                                      DataCell(
                                        config.taxAccountId != null
                                            ? Text(
                                                '${config.taxAccount?.name ?? ""} (${config.taxPercentage}%)',
                                              )
                                            : const Text(
                                                'N/A',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      if (isAdmin)
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Eliminar operación',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmar Eliminación',
                                                  ),
                                                  content: Text(
                                                    '¿Estás seguro de eliminar la configuración de ${config.name}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Eliminar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await ref
                                                    .read(
                                                      accountingEngineConfigProvider
                                                          .notifier,
                                                    )
                                                    .deleteConfig(config.id);
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
