import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/accounting/presentation/screens/accounts_screen.dart';
import '../../features/accounting/presentation/screens/accounting_operations_screen.dart';
import '../../features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import '../../features/cashier/presentation/screens/cash_reconciliation_screen.dart';
import '../../features/cashier/presentation/screens/cash_history_screen.dart';
import '../../features/cashier/presentation/screens/all_cash_history_screen.dart';
import '../../features/finance/presentation/screens/finance_dashboard_screen.dart';
import '../../features/finance/presentation/screens/journal_screen.dart';
import '../../features/finance/presentation/screens/ledger_screen.dart';
import '../../features/provicional/presentation/screens/ingreso_provicional_screen.dart';
import '../../features/provicional/presentation/screens/gasto_provicional_screen.dart';
import '../../features/provicional/presentation/screens/provicional_dashboard_screen.dart';
import '../../features/donations/presentation/screens/donation_screen.dart';
import '../../features/donations/presentation/screens/donation_history_screen.dart';
import '../../features/users/presentation/screens/users_crud_screen.dart';
import '../../features/finance/bank/presentation/screens/bank_accounts_screen.dart';
import '../../features/finance/bank/presentation/screens/bank_account_detail_screen.dart';
import '../../features/finance/bank/presentation/screens/bank_reconciliation_screen.dart';
import '../../features/users/presentation/screens/profile_screen.dart';
import '../presentation/layout/main_layout.dart';

// Clave del navegador raíz
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    // redirect reacciona a los cambios en authState gracias a ref.watch
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';

      // Si está inicializando la app, siempre mostrar el splash
      if (authState == AuthState.initial) {
        return isSplash ? null : '/splash';
      }

      // Si está cargando (ej. revisando sesión o haciendo login)
      if (authState == AuthState.loading) {
        // Si ya estamos en la pantalla de login, NO queremos ir al splash.
        // Queremos quedarnos aquí para que se vea el ChurchLoadingDialog.
        if (isGoingToLogin) return null;
        return isSplash ? null : '/splash';
      }

      final isAuthenticated = authState == AuthState.authenticated;

      // Si terminó de cargar y estamos en el splash, decidir a dónde ir
      if (isSplash) {
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // Si no está autenticado y NO va al login, envíalo al login
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      // Si está autenticado y trata de ir al login, envíalo al dashboard
      if (isAuthenticated && isGoingToLogin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/accounting/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/accounting/operations',
            builder: (context, state) => const AccountingOperationsScreen(),
          ),
          GoRoute(
            path: '/cashier',
            builder: (context, state) => const CashierDashboardScreen(),
          ),
          GoRoute(
            path: '/cashier/reconciliation',
            builder: (context, state) => const CashReconciliationScreen(),
          ),
          GoRoute(
            path: '/cashier/history',
            builder: (context, state) => const CashHistoryScreen(),
          ),
          GoRoute(
            path: '/all-cash-history',
            builder: (context, state) => const AllCashHistoryScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceDashboardScreen(),
          ),
          GoRoute(
            path: '/finance/journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: '/finance/ledger',
            builder: (context, state) => const LedgerScreen(),
          ),
          GoRoute(
            path: '/provicional/ingresos',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: IngresoProvicionalScreen()),
          ),
          GoRoute(
            path: '/donations/create',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DonationScreen()),
          ),
          GoRoute(
            path: '/donations/history',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DonationHistoryScreen()),
          ),
          GoRoute(
            path: '/bank/accounts',
            builder: (context, state) => const BankAccountsScreen(),
          ),
          GoRoute(
            path: '/bank/accounts/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BankAccountDetailScreen(accountId: id);
            },
          ),
          GoRoute(
            path: '/bank/accounts/:id/reconcile',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BankReconciliationScreen(accountId: id);
            },
          ),
          GoRoute(
            path: '/provicional/gastos',
            builder: (context, state) => const GastoProvicionalScreen(),
          ),
          GoRoute(
            path: '/provicional/dashboard',
            builder: (context, state) => const ProvicionalDashboardScreen(),
          ),
          GoRoute(
            path: '/settings/users',
            builder: (context, state) => const UsersCrudScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // Más rutas irán aquí adentro de ShellRoute
        ],
      ),
    ],
  );
});
