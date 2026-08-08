import 'package:flutter/material.dart';

import '../../theme/church_colors.dart';

Future<bool?> showChurchConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = 'Cancelar',
  String confirmText = 'Confirmar',
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ChurchColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ChurchColors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        cancelText,
                        style: const TextStyle(color: ChurchColors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor ?? ChurchColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
