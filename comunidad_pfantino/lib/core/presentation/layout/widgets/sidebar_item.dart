import 'package:flutter/material.dart';

import '../../../theme/church_colors.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ChurchColors.primary.withValues(alpha: 0.1)
                : isHovered
                ? ChurchColors.lightGrey.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? ChurchColors.primary
                    : ChurchColors.grey,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isSelected
                        ? ChurchColors.primary
                        : ChurchColors.black,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ChurchColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
