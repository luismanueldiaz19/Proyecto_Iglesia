import 'package:flutter/material.dart';
import '../../theme/church_colors.dart';

class ModernLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const ModernLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              // Este fondo absorbe los clicks y oscurece la pantalla ligeramente
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, value, _) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4.5,
                                  strokeCap: StrokeCap.round,
                                  valueColor: const AlwaysStoppedAnimation<Color>(ChurchColors.primary),
                                  backgroundColor: ChurchColors.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              if (message != null) ...[
                                const SizedBox(height: 20),
                                Text(
                                  message!,
                                  style: const TextStyle(
                                    color: ChurchColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                    decoration: TextDecoration.none, // En caso de que se use fuera de un Scaffold
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
      ],
    );
  }
}
