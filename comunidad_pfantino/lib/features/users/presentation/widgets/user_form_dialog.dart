import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_dropdown_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../providers/users_provider.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final UserEntity? user;
  const UserFormDialog({super.key, this.user});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  String _selectedRole = 'Cajera';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _passwordController = TextEditingController();
    if (widget.user != null) {
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (widget.user == null) {
          await ref
              .read(usersProvider.notifier)
              .createUser(
                _nameController.text.trim(),
                _usernameController.text.trim(),
                _passwordController.text,
                _selectedRole,
              );
        } else {
          await ref
              .read(usersProvider.notifier)
              .updateUser(
                widget.user!.id!,
                _nameController.text.trim(),
                _usernameController.text.trim(),
                _passwordController.text.isEmpty
                    ? null
                    : _passwordController.text,
                _selectedRole,
              );
        }
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.user == null ? 'Usuario creado' : 'Usuario actualizado',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString().replaceAll('Exception: ', '')}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Nombre Completo',
                prefixIcon: Icons.person,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Nombre de Usuario',
                prefixIcon: Icons.alternate_email,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: widget.user == null
                    ? 'Contraseña'
                    : 'Nueva Contraseña (Opcional)',
                prefixIcon: Icons.lock,
                obscureText: true,
                validator: (v) {
                  if (widget.user == null && (v == null || v.isEmpty)) {
                    return 'Requerida';
                  }
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomDropdownField<String>(
                value: _selectedRole,
                labelText: 'Rol',
                items: const [
                  DropdownMenuItem(
                    value: 'Administrador',
                    child: Text('Administrador'),
                  ),
                  DropdownMenuItem(value: 'Cajera', child: Text('Cajera')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedRole = v);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        PrimaryButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          text: 'Cancelar',
          isOutlined: true,
          width: null,
        ),
        PrimaryButton(
          onPressed: _isLoading ? null : _submit,
          text: 'Guardar',
          isLoading: _isLoading,
          width: null,
          icon: Icons.save,
        ),
      ],
    );
  }
}
