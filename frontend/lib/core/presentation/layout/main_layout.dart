import 'package:flutter/material.dart';

import '../../theme/church_colors.dart';
import '../../config/app_info.dart';
import 'widgets/sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: ChurchColors.background, // Fondo gris muy claro general
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: ChurchColors.white,
              foregroundColor: ChurchColors.black,
              elevation: 0,
              title: const Text(
                AppInfo.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              centerTitle: true,
            ),
      drawer: isDesktop ? null : const Drawer(child: Sidebar()),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
