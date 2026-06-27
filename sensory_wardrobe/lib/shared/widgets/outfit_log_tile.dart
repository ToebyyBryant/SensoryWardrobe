import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../features/outfit_log/data/models/outfit_log_model.dart';
import '../../features/outfit_log/data/models/comfort_rating_model.dart';
import 'comfort_score_badge.dart';

/// A single row in the outfit history list.
class OutfitLogTile extends StatelessWidget {
  final OutfitLogModel log;
  final ComfortRatingModel? rating;
  final VoidCallback? onTap;

  const OutfitLogTile({
    super.key,
    required this.log,
    this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEE, MMM d').format(log.loggedDate);
    final itemCount = log.itemIds.length;

    return ListTile(
      onTap: onTap,
      leading: rating != null
          ? ComfortScoreBadge(score: rating!.overallScore)
          : Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.cardBorder,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline,
                  size: 16, color: AppColors.textMuted),
            ),
      title: Text(
        dateLabel,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$itemCount item${itemCount == 1 ? '' : 's'} worn'
        '${rating != null ? '  •  Rated ${rating!.overallScore}/5' : '  •  Not yet rated'}',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}
