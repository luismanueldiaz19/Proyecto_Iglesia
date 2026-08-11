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
                  SidebarItem(
                    icon: Icons.history_edu_rounded,
                    title: 'Todos Cuadre',
                    isSelected: currentPath == '/all-cash-history',
                    onTap: () => context.go('/all-cash-history'),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Operaciones'),
                  SidebarItem(
                    icon: Icons.point_of_sale_rounded,
                    title: 'Cajero (Cuadre)',
                    isSelected: currentPath.startsWith('/cashier'),
                    onTap: () => context.go('/cashier'),
                  ),
                  SidebarItem(
                    icon: Icons.arrow_circle_down_rounded,
                    title: 'Ingresos',
                    isSelected: currentPath == '/provicional/ingresos',
                    onTap: () => context.go('/provicional/ingresos'),
                  ),
                  SidebarItem(
                    icon: Icons.arrow_circle_up_rounded,
                    title: 'Gastos',
                    isSelected: currentPath == '/provicional/gastos',
                    onTap: () => context.go('/provicional/gastos'),
                  ),
                  SidebarItem(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Dashboard',
                    isSelected: currentPath == '/provicional/dashboard',
                    onTap: () => context.go('/provicional/dashboard'),
                  ),

                  // SidebarItem(
                  //   icon: Icons.picture_as_pdf_rounded,
                  //   title: 'Reportes',
                  //   isSelected: currentPath == '/provicional/reportes',
                  //   onTap: () => context.go('/provicional/reportes'),
                  // ),
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
                    title: 'Recibir Donación',
                    isSelected: currentPath == '/donations/create',
                    onTap: () => context.go('/donations/create'),
                  ),
                  SidebarItem(
                    icon: Icons.history_rounded,
                    title: 'Historial Donaciones',
                    isSelected: currentPath == '/donations/history',
                    onTap: () => context.go('/donations/history'),
                  ),

                  // const SizedBox(height: 16),
                  // _buildSectionHeader('Comercio y Stock'),
                  // SidebarItem(
                  //   icon: Icons.storefront_rounded,
                  //   title: 'Tienda / Librería',
                  //   isSelected: currentPath.startsWith('/store'),
                  //   onTap: () {},
                  // ),
                  // SidebarItem(
                  //   icon: Icons.local_cafe_rounded,
                  //   title: 'Cafetería',
                  //   isSelected: currentPath.startsWith('/cafe'),
                  //   onTap: () {},
                  // ),
                  // SidebarItem(
                  //   icon: Icons.inventory_2_rounded,
                  //   title: 'Inventario',
                  //   isSelected: currentPath.startsWith('/inventory'),
                  //   onTap: () {},
                  // ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Finanzas'),
                  SidebarItem(
                    icon: Icons.account_balance_rounded,
                    title: 'Libros Contables',
                    isSelected:
                        currentPath == '/finance' ||
                        currentPath.startsWith('/finance/'),
                    onTap: () => context.go('/finance'),
                  ),
                  SidebarItem(
                    icon: Icons.list_alt_rounded,
                    title: 'Catálogo de Cuentas',
                    isSelected: currentPath.startsWith('/accounting/accounts'),
                    onTap: () => context.go('/accounting/accounts'),
                  ),
                  SidebarItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Bancos / Cuentas',
                    isSelected: currentPath.startsWith('/bank/accounts'),
                    onTap: () => context.go('/bank/accounts'),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Administración'),
                  if (ref.watch(authProvider.notifier).currentUser?.role ==
                      'Administrador')
                    SidebarItem(
                      icon: Icons.settings_rounded,
                      title: 'Gestión de Usuarios',
                      isSelected: currentPath == '/settings/users',
                      onTap: () => context.go('/settings/users'),
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
