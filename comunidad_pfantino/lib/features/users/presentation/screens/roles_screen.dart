import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../providers/roles_provider.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      backgroundColor: ChurchColors.background,
      appBar: AppBar(
        backgroundColor: ChurchColors.white,
        title: const Text(
          'Roles y Permisos',
          style: TextStyle(
            color: ChurchColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: ChurchColors.primary),
        elevation: 0,
      ),
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No hay roles configurados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      role.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: ChurchColors.primary,
                      ),
                    ),
                    subtitle: Text(
                      '${role.permissions.length} Permisos asignados',
                      style: const TextStyle(color: ChurchColors.grey),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ChurchColors.lightGrey.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: role.permissions.isEmpty
                            ? const Text(
                                'Este rol no tiene permisos asignados.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              )
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: role.permissions.map((perm) {
                                  return Chip(
                                    label: Text(
                                      perm.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ChurchColors.primary,
                                      ),
                                    ),
                                    backgroundColor: ChurchColors.white,
                                    side: const BorderSide(
                                      color: ChurchColors.primary,
                                      width: 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: ChurchColors.primary),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ocurrió un error al cargar los roles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(rolesProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChurchColors.primary,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
