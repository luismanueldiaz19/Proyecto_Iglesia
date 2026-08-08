import 'package:flutter/material.dart';
import '../../theme/church_colors.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final bool isOutlined;
  final Color? color;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width = double.infinity,
    this.icon,
    this.isOutlined = false,
    this.color,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? ChurchColors.primary;
    
    final content = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: isOutlined ? buttonColor : ChurchColors.white,
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: 52,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonColor,
                side: BorderSide(color: buttonColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: content,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: ChurchColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: content,
            ),
    );
  }
}
