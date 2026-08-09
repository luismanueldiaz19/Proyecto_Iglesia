import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_info.dart';
import 'core/router/app_router.dart';
import 'core/theme/church_theme.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos SharedPreferences de forma asíncrona antes de arrancar la app
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Sobreescribimos el valor del provider con la instancia real
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const IglesiaApp(),
    ),
  );
}

class IglesiaApp extends ConsumerWidget {
  const IglesiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el router que ya tiene la lógica de redirección basada en la sesión
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: churchTheme,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: router,
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
