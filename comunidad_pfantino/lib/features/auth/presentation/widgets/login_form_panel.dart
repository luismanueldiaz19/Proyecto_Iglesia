import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/church_colors.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/church_loading_dialog.dart';
import '../../providers/auth_provider.dart';
import 'test_credentials_button.dart';

class LoginFormPanel extends ConsumerStatefulWidget {
  const LoginFormPanel({super.key});

  @override
  ConsumerState<LoginFormPanel> createState() => _LoginFormPanelState();
}

class _LoginFormPanelState extends ConsumerState<LoginFormPanel> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();

    ChurchLoadingDialog.show(
      context,
      title: 'Iniciando Sesión',
      message: 'Verificando credenciales...',
    );

    final nav = Navigator.of(context, rootNavigator: true);

    await Future.delayed(const Duration(seconds: 2));

    await ref
        .read(authProvider.notifier)
        .login(_usernameController.text, _passwordController.text);

    if (nav.canPop()) {
      nav.pop();
    }
  }

  void _fillTestCredentials() {
    _usernameController.text =
        'ludeveloper'; // Cambia esto por un usuario de prueba real
    _passwordController.text = '199512'; // Cambia esto por tu clave de prueba
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final isMobile = MediaQuery.of(context).size.width <= 800;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 16.0 : 24.0;
    final spacing = isMobile ? 12.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puedes comentar este componente cuando ya no necesites el autocompletado
          TestCredentialsButton(onFill: _fillTestCredentials),

          Text(
            'Hola, Bienvenido',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : null,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            'Accede a tu cuenta para continuar',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: ChurchColors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          if (authState == AuthState.error)
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              margin: EdgeInsets.only(bottom: isMobile ? 16 : 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                authNotifier.errorMessage ?? 'Error desconocido',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          CustomTextField(
            controller: _usernameController,
            hintText: 'Usuario',
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: spacing),
          CustomTextField(
            controller: _passwordController,
            hintText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          PrimaryButton(
            onPressed: authState == AuthState.loading ? null : _onLogin,
            text: 'Ingresar',
            isLoading: authState == AuthState.loading,
          ),
          SizedBox(height: spacing),
          Center(
            child: RichText(
              text: TextSpan(
                text: '¿No tienes cuenta? ',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black38,
                  fontSize: isMobile ? 12 : 14,
                ),
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
