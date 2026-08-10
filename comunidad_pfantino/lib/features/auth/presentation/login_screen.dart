import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../../core/config/app_info.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'admin'; // Para el switcher de llenado rápido

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    ref
        .read(authProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            height: isDesktop ? 600 : null,
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ChurchColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ), // Sombra suave premium
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            clipBehavior: Clip
                .antiAlias, // Redondea perfectamente los hijos sin bordes blancos
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              children: [
                // PANEL IZQUIERDO (Imagen)
                if (isDesktop)
                  Expanded(
                    flex: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/login_bg.png', fit: BoxFit.cover),
                        // Overlay oscuro/gradiente para el texto
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppInfo.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 14,
                                ),
                              ),
                              Spacer(),
                              Text(
                                AppInfo.subtitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppInfo.description,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // PANEL DERECHO (Formulario)
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 48.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isDesktop) ...[
                          const Center(
                            child: Icon(
                              Icons.church_rounded,
                              size: 60,
                              color: ChurchColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const Text(
                          'Hola, Bienvenido',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: ChurchColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Accede a tu cuenta para continuar',
                          style: TextStyle(
                            fontSize: 14,
                            color: ChurchColors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SWITCHER DE LLENADO RÁPIDO (SOLO PARA PRUEBAS) - COMENTADO A PETICIÓN
                        /*
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ChurchColors.lightGrey.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = 'admin';
                                      _usernameController.text = 'ludeveloper';
                                      _passwordController.text = '199512';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'admin'
                                          ? ChurchColors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedRole == 'admin'
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Administrador',
                                      style: TextStyle(
                                        fontWeight: _selectedRole == 'admin'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _selectedRole == 'admin'
                                            ? ChurchColors.primary
                                            : ChurchColors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = 'cajera1';
                                      _usernameController.text = 'cajera1';
                                      _passwordController.text = '123456';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'cajera1'
                                          ? ChurchColors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedRole == 'cajera1'
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Cajera',
                                      style: TextStyle(
                                        fontWeight: _selectedRole == 'cajera1'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _selectedRole == 'cajera1'
                                            ? ChurchColors.primary
                                            : ChurchColors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        */

                        if (authState == AuthState.error)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authNotifier.errorMessage ?? 'Error desconocido',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        CustomTextField(
                          controller: _usernameController,
                          hintText: 'Usuario',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: ChurchColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        PrimaryButton(
                          onPressed: authState == AuthState.loading
                              ? null
                              : _onLogin,
                          text: 'Ingresar',
                          isLoading: authState == AuthState.loading,
                        ),
                        const SizedBox(height: 32),

                        Center(
                          child: RichText(
                            text: const TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: TextStyle(
                                color: ChurchColors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Solicitar acceso',
                                  style: TextStyle(
                                    color: ChurchColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}
