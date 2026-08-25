import 'package:flutter/material.dart';
import '../../theme/church_colors.dart';

class ChurchLoadingDialog extends StatefulWidget {
  final String title;
  final String message;

  const ChurchLoadingDialog({
    super.key,
    this.title = 'Cargando',
    this.message = 'Por favor espere...',
  });

  static void show(
    BuildContext context, {
    String title = 'Cargando',
    String message = 'Por favor espere...',
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // Color de fondo habitual de los dialogos
      transitionDuration: const Duration(
        milliseconds: 600,
      ), // Suficiente tiempo para el efecto elástico
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,
          child: ChurchLoadingDialog(title: title, message: message),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Curva elástica para el efecto de rebote/zoom in
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(scale: curve, child: child);
      },
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  State<ChurchLoadingDialog> createState() => _ChurchLoadingDialogState();
}

class _ChurchLoadingDialogState extends State<ChurchLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const CircleBorder(),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Borde luminoso giratorio
            RotationTransition(
              turns: _spinController,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      ChurchColors.gold.withValues(alpha: 0.1),
                      ChurchColors.gold.withValues(alpha: 0.8),
                      ChurchColors.gold,
                    ],
                    stops: const [0.0, 0.5, 0.95, 1.0],
                  ),
                ),
              ),
            ),
            // Círculo interior blanco
            Container(
              width: 294, // Deja un borde de 3px
              height: 294,
              decoration: const BoxDecoration(
                color: ChurchColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 48,
                        color: ChurchColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const CandlesLoadingIndicator(),
                      const SizedBox(height: 32),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ChurchColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ChurchColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CandlesLoadingIndicator extends StatefulWidget {
  const CandlesLoadingIndicator({super.key});

  @override
  State<CandlesLoadingIndicator> createState() =>
      _CandlesLoadingIndicatorState();
}

class _CandlesLoadingIndicatorState extends State<CandlesLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // La animación dura 2 segundos y se repite
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCandle(bool isLit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Llama de la vela
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isLit ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: isLit
                  ? [
                      BoxShadow(
                        color: ChurchColors.gold.withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: ChurchColors.goldLight,
              size: 20,
            ),
          ),
        ),
        // Pabilo (hilo)
        Container(width: 2, height: 4, color: Colors.grey.shade400),
        // Cuerpo de la vela
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 14,
          height: 22,
          decoration: BoxDecoration(
            color: isLit ? Colors.white : Colors.transparent,
            border: Border.all(
              color: isLit ? ChurchColors.gold : Colors.grey.shade400,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        // Base de la vela
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 22,
          height: 4,
          decoration: BoxDecoration(
            color: isLit ? ChurchColors.gold : Colors.transparent,
            border: Border.all(
              color: isLit ? ChurchColors.gold : Colors.grey.shade400,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculamos qué velas están encendidas.
        // 0 a 5 encienden de izq a der. 6 a 11 se apagan de izq a der.
        int step = (_controller.value * 12).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (index) {
            bool isLit = false;
            if (step < 6) {
              // Fase de encendido
              isLit = index <= step;
            } else {
              // Fase de apagado (ASC: de izquierda a derecha se apagan)
              isLit = index > (step - 6);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildCandle(isLit),
            );
          }),
        );
      },
    );
  }
}
