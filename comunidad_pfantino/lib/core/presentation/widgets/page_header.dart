import 'package:flutter/material.dart';
import '../../theme/church_colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? actionButton;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: ChurchColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: ChurchColors.grey),
              ),
            ],
          ),
        ),
        if (actionButton != null) ...[const SizedBox(width: 16), actionButton!],
      ],
    );
  }
}
