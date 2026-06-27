import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Displays a single sensory tag as a read-only chip.
class SensoryTagChip extends StatelessWidget {
  final String tag;
  final bool selected;
  final VoidCallback? onTap;

  const SensoryTagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(tag),
        backgroundColor:
            selected ? AppColors.teal.withValues(alpha: 0.15) : null,
        side: BorderSide(
          color: selected ? AppColors.teal : AppColors.cardBorder,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.teal : AppColors.textMid,
          fontWeight:
              selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
