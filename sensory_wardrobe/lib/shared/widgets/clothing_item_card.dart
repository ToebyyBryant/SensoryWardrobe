import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/wardrobe/data/models/clothing_item_model.dart';
import 'sensory_tag_chip.dart';

/// Reusable card for displaying a clothing item in lists/grids.
class ClothingItemCard extends StatelessWidget {
  final ClothingItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;

  const ClothingItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo or placeholder
              _ItemPhoto(photoPath: item.photoPath),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + category
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),

                    // Warmth level
                    if (item.warmthLevel != null) ...[
                      const SizedBox(height: 4),
                      _WarmthIndicator(level: item.warmthLevel!),
                    ],

                    // Sensory tags (first 3)
                    if (item.sensoryTags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: item.sensoryTags
                            .take(3)
                            .map((tag) => SensoryTagChip(
                                  tag: tag,
                                  selected: true,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Archive action
              if (onArchive != null)
                IconButton(
                  icon: const Icon(Icons.archive_outlined,
                      color: AppColors.textMuted),
                  tooltip: 'Archive item',
                  onPressed: onArchive,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemPhoto extends StatelessWidget {
  final String? photoPath;
  const _ItemPhoto({this.photoPath});

  @override
  Widget build(BuildContext context) {
    const size = 64.0;

    if (photoPath != null && photoPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(photoPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(size),
        ),
      );
    }
    return _placeholder(size);
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.checkroom_outlined,
          color: AppColors.textMuted, size: 28),
    );
  }
}

class _WarmthIndicator extends StatelessWidget {
  final int level; // 1–5

  const _WarmthIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < level ? Icons.circle : Icons.circle_outlined,
          size: 8,
          color: i < level ? AppColors.teal : AppColors.cardBorder,
        );
      }),
    );
  }
}
