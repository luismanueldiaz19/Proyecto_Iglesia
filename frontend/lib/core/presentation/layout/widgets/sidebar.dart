import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/config/app_info.dart';
import '../../../theme/church_colors.dart';
import 'sidebar_item.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: ChurchColors.white,
        border: Border(
          right: BorderSide(color: ChurchColors.lightGrey, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo y Cabecera
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(
                  Icons.church_rounded,
                  color: ChurchColors.primary,
                  size: 36,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppInfo.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: ChurchColors.black,
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        AppInfo.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: ChurchColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menú Principal
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Principal'),
                  SidebarItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: currentPath == '/dashboard',
                    onTap: () => context.go('/dashboard'),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Gestión'),
                  SidebarItem(
                    icon: Icons.point_of_sale_rounded,
                    title: 'Cajero (Cuadre)',
                    isSelected: currentPath.startsWith('/cashier'),
                    onTap: () => context.go('/cashier'),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Ingresos'),
                  SidebarItem(
                    icon: Icons.favorite_rounded,
                    title: 'Ofrendas y Diezmos',
                    isSelected: currentPath.startsWith('/offerings'),
                    onTap: () {},
                  ),
                  SidebarItem(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Donaciones',
                    isSelected: currentPath.startsWith('/donations'),
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Comercio y Stock'),
                  SidebarItem(
                    icon: Icons.storefront_rounded,
                    title: 'Tienda / Librería',
                    isSelected: currentPath.startsWith('/store'),
                    onTap: () {},
                  ),
                  SidebarItem(
                    icon: Icons.local_cafe_rounded,
                    title: 'Cafetería',
                    isSelected: currentPath.startsWith('/cafe'),
                    onTap: () {},
                  ),
                  SidebarItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Inventario',
                    isSelected: currentPath.startsWith('/inventory'),
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Finanzas'),
                  SidebarItem(
                    icon: Icons.account_balance_rounded,
                    title: 'Finanzas',
                    isSelected: currentPath == '/finance' || currentPath.startsWith('/finance/'),
                    onTap: () => context.go('/finance'),
                  ),
                  SidebarItem(
                    icon: Icons.list_alt_rounded,
                    title: 'Catálogo de Cuentas',
                    isSelected: currentPath.startsWith('/accounting/accounts'),
                    onTap: () => context.go('/accounting/accounts'),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Administración'),
                  SidebarItem(
                    icon: Icons.settings_rounded,
                    title: 'Configuración',
                    isSelected: currentPath == '/settings',
                    onTap: () {},
                  ),
                  SidebarItem(
                    icon: Icons.settings_applications_rounded,
                    title: 'Config. Contable',
                    isSelected: currentPath.startsWith(
                      '/accounting/operations',
                    ),
                    onTap: () => context.go('/accounting/operations'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Footer del Sidebar (Perfil de usuario y Logout)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: ChurchColors.lightGrey, width: 1),
              ),
            ),
            child: Column(
              children: [
                SidebarItem(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar Sesión',
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ChurchColors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
