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
import '../../features/finance/presentation/screens/finance_dashboard_screen.dart';
import '../../features/finance/presentation/screens/journal_screen.dart';
import '../../features/finance/presentation/screens/ledger_screen.dart';
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

      // Si está inicializando la app o comprobando la sesión, mostrar el splash
      if (authState == AuthState.loading || authState == AuthState.initial) {
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
          // Más rutas irán aquí adentro de ShellRoute
        ],
      ),
    ],
  );
});
