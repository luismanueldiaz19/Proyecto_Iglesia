import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/church_colors.dart';
import '../../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider.notifier);
    final user = authState.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, ${user?.username ?? 'Usuario'}!',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: ChurchColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rol actual: ${user?.role ?? 'Desconocido'}',
            style: const TextStyle(
              fontSize: 16,
              color: ChurchColors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Placeholder para widgets futuros (gráficos, tarjetas de resumen, etc)
          Container(
            padding: const EdgeInsets.all(32),
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
            child: const Center(
              child: Text(
                'Aquí se mostrará el resumen del sistema (Ingresos del día, alertas de inventario, etc.)',
                style: TextStyle(color: ChurchColors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
