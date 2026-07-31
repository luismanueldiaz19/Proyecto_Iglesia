import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/accounting_provider.dart';
import '../widgets/create_account_dialog.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountingState = ref.watch(accountingProvider);
    final user = ref.read(authProvider.notifier).currentUser;
    final isAdmin = user?.role == 'admin' || user?.role == 'Administrador';

    return Scaffold(
      backgroundColor: Colors.transparent, // Tomará el fondo del MainLayout
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo de Cuentas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: ChurchColors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Administra las cuentas contables y bancos de la iglesia',
                      style: TextStyle(color: ChurchColors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateAccountDialog(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nueva Cuenta'),
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
                child: accountingState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : accountingState.error != null
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
                              accountingState.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref
                                  .read(accountingProvider.notifier)
                                  .loadAccounts(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              ChurchColors.lightGrey.withValues(alpha: 0.3),
                            ),
                            columns: [
                              const DataColumn(
                                label: Text(
                                  'Código',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Nombre',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Tipo',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Transaccional',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                            rows: accountingState.accounts.map((account) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      account.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(account.name)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(account.type)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        account.type,
                                        style: TextStyle(
                                          color: _getTypeColor(account.type),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Icon(
                                      account.isTransactional
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: account.isTransactional
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  if (isAdmin)
                                    DataCell(
                                      [
                                            '1000',
                                            '2000',
                                            '3000',
                                            '4000',
                                            '5000',
                                          ].contains(account.code)
                                          ? const SizedBox.shrink()
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                              ),
                                              tooltip: 'Eliminar cuenta',
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      'Confirmar Eliminación',
                                                    ),
                                                    content: Text(
                                                      '¿Estás seguro de eliminar la cuenta ${account.name}?',
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
                                                  final success = await ref
                                                      .read(
                                                        accountingProvider
                                                            .notifier,
                                                      )
                                                      .deleteAccount(
                                                        account.id,
                                                      );
                                                  if (!success &&
                                                      context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          ref
                                                                  .read(
                                                                    accountingProvider,
                                                                  )
                                                                  .error ??
                                                              'Error al eliminar',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                    ref
                                                        .read(
                                                          accountingProvider
                                                              .notifier,
                                                        )
                                                        .clearError();
                                                  }
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
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Activo':
        return Colors.blue;
      case 'Pasivo':
        return Colors.red;
      case 'Capital':
        return Colors.purple;
      case 'Ingreso':
        return Colors.green;
      case 'Gasto':
        return Colors.orange;
      default:
        return ChurchColors.grey;
    }
  }
}
