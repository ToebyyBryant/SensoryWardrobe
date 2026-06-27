import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable widget that displays a comfort score (1–5) as a colored badge.
class ComfortScoreBadge extends StatelessWidget {
  final int score;
  final double size;

  const ComfortScoreBadge({super.key, required this.score, this.size = 32});

  Color get _color {
    switch (score) {
      case 1:
        return AppColors.comfortVeryLow;
      case 2:
        return AppColors.comfortLow;
      case 3:
        return AppColors.comfortMid;
      case 4:
        return AppColors.comfortHigh;
      case 5:
        return AppColors.comfortVeryHigh;
      default:
        return AppColors.textMuted;
    }
  }

  String get _label {
    switch (score) {
      case 1:
        return 'Very Uncomfortable';
      case 2:
        return 'Uncomfortable';
      case 3:
        return 'Neutral';
      case 4:
        return 'Comfortable';
      case 5:
        return 'Very Comfortable';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          score.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
