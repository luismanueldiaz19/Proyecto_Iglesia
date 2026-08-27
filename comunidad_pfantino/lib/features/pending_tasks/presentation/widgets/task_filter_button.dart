import 'package:flutter/material.dart';
import '../../../../core/theme/church_colors.dart';

class TaskFilterButton extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskFilterButton({
    super.key,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ChurchColors.primary.withValues(alpha: 0.1)
              : ChurchColors.white,
          border: Border.all(
            color: isSelected ? ChurchColors.primary : ChurchColors.lightGrey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            color: isSelected ? ChurchColors.primary : ChurchColors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
