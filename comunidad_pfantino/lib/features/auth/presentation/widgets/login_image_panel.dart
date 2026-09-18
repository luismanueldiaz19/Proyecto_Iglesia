import 'package:flutter/material.dart';
import '../../../../core/config/app_info.dart';

class LoginImagePanel extends StatelessWidget {
  const LoginImagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Stack(
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
        Padding(
          padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.name,
                style: textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : null,
                ),
              ),
              const Spacer(),
              Text(
                AppInfo.subtitle,
                style: textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  fontSize: isMobile ? 16 : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppInfo.description,
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontSize: isMobile ? 11 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
