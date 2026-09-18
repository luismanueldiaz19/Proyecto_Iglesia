import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestCredentialsButton extends StatelessWidget {
  final VoidCallback onFill;

  const TestCredentialsButton({
    super.key,
    required this.onFill,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onFill,
        icon: const Icon(Icons.bug_report, size: 16, color: Colors.orange),
        label: const Text(
          'Autocompletar Prueba',
          style: TextStyle(fontSize: 12, color: Colors.orange),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
