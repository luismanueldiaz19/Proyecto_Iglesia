import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/church_loading_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(
      text: ref.read(authProvider.notifier).currentUser?.name ?? '',
    );
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Nombre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChurchColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nuevo Nombre',
                      prefixIcon: const Icon(
                        Icons.person,
                        color: ChurchColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Requerido',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: ChurchColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Requerido',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: ChurchColors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        width: 120,
                        text: 'Guardar',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            ChurchLoadingDialog.show(
                              context,
                              title: 'Guardando',
                              message: 'Actualizando perfil...',
                            );
                            final nav = Navigator.of(
                              context,
                              rootNavigator: true,
                            );

                            try {
                              await ref
                                  .read(profileProvider.notifier)
                                  .updateName(
                                    nameController.text,
                                    passwordController.text,
                                  );

                              if (nav.canPop()) nav.pop(); // Cierra loading

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx); // Cierra modal de edición

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil actualizado'),
                                ),
                              );
                            } catch (e) {
                              if (nav.canPop()) nav.pop(); // Cierra loading

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ChurchColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: ChurchColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Requerido',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: ChurchColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v != null && v.length >= 6
                        ? null
                        : 'Mínimo 6 caracteres',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: ChurchColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v == newPasswordController.text ? null : 'No coinciden',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: ChurchColors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        width: 120,
                        text: 'Cambiar',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            ChurchLoadingDialog.show(
                              context,
                              title: 'Actualizando',
                              message: 'Cambiando contraseña...',
                            );
                            final nav = Navigator.of(
                              context,
                              rootNavigator: true,
                            );

                            try {
                              await ref
                                  .read(profileProvider.notifier)
                                  .changePassword(
                                    currentPasswordController.text,
                                    newPasswordController.text,
                                    confirmPasswordController.text,
                                  );

                              if (nav.canPop()) nav.pop(); // Cierra loading

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx); // Cierra modal

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contraseña cambiada exitosamente',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (nav.canPop()) nav.pop(); // Cierra loading

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider.notifier);
    final user = authState.currentUser;
    final profileState = ref.watch(profileProvider);
    final sessionsAsync = ref.watch(profileSessionsProvider);
    final permissionsAsync = ref.watch(profilePermissionsProvider);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 280),
                decoration: BoxDecoration(
                  color: ChurchColors.primary,
                  image: user?.profilePhotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(
                            user!.profilePhotoUrl!,
                            headers: {
                              'Authorization':
                                  'Bearer ${ref.read(authProvider.notifier).getToken()}',
                            },
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 24,
                right: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image, withData: true);

                          if (result != null &&
                              result.files.single.bytes != null) {
                            if (!context.mounted) return;
                            ChurchLoadingDialog.show(
                              context,
                              title: 'Subiendo',
                              message: 'Actualizando foto...',
                            );
                            final nav = Navigator.of(
                              context,
                              rootNavigator: true,
                            );

                            try {
                              await ref
                                  .read(profileProvider.notifier)
                                  .uploadPhoto(
                                    result.files.single.bytes!,
                                    result.files.single.name,
                                  );
                              if (nav.canPop()) nav.pop();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Foto actualizada exitosamente',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (nav.canPop()) nav.pop();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          // Error al abrir el selector
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ChurchColors.white,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: ChurchColors.primary,
                              backgroundImage: user?.profilePhotoUrl != null
                                  ? NetworkImage(
                                      user!.profilePhotoUrl!,
                                      headers: {
                                        'Authorization':
                                            'Bearer ${ref.read(authProvider.notifier).getToken()}',
                                      },
                                    )
                                  : null,
                              child: user?.profilePhotoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: ChurchColors.white,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ChurchColors.gold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ChurchColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: ChurchColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user?.name ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user?.username}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ChurchColors.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ChurchColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              user?.role ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileState.isLoading)
                  const Center(
                    child: LinearProgressIndicator(color: ChurchColors.primary),
                  ),
                const SizedBox(height: 16),

                // Actions
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                      elevation: 0,
                      color: ChurchColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: ChurchColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            leading: const Icon(
                              Icons.edit,
                              color: ChurchColors.primary,
                            ),
                            title: const Text(
                              'Editar Nombre',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: ChurchColors.grey,
                            ),
                            onTap: () => _showEditNameDialog(context, ref),
                          ),
                          const Divider(
                            height: 1,
                            color: ChurchColors.lightGrey,
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            leading: const Icon(
                              Icons.lock,
                              color: ChurchColors.primary,
                            ),
                            title: const Text(
                              'Cambiar Contraseña',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: ChurchColors.grey,
                            ),
                            onTap: () =>
                                _showChangePasswordDialog(context, ref),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Permisos
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Permisos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: ChurchColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        permissionsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: ChurchColors.primary,
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Text('Error al cargar permisos: $err'),
                          ),
                          data: (permissions) {
                            if (permissions.isEmpty) {
                              return const Text(
                                'No tienes permisos especiales asignados.',
                                style: TextStyle(color: ChurchColors.grey),
                              );
                            }
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: permissions.map((permission) {
                                return Chip(
                                  label: Text(permission),
                                  backgroundColor: ChurchColors.primary
                                      .withValues(alpha: 0.05),
                                  side: BorderSide(
                                    color: ChurchColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Sessions
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Accesos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: ChurchColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        sessionsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: ChurchColors.primary,
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Text('Error al cargar accesos: $err'),
                          ),
                          data: (sessions) {
                            if (sessions.isEmpty) {
                              return const Text(
                                'No hay accesos registrados.',
                                style: TextStyle(color: ChurchColors.grey),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final session = sessions[index];
                                return Card(
                                  elevation: 0,
                                  color: ChurchColors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: ChurchColors.lightGrey,
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: ChurchColors.background,
                                      child: Icon(
                                        Icons.devices,
                                        color: ChurchColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      session['ip_address'] ?? 'IP Desconocida',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session['user_agent'] ??
                                              'Navegador desconocido',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: ChurchColors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Última act: ${session['last_activity']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ChurchColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
