import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/clothing_item_card.dart';
import '../providers/wardrobe_providers.dart';

/// P2.0 — Wardrobe Catalog Screen
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wardrobeItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add clothing item',
            onPressed: () => context.push(AppRoutes.addClothingItem),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load wardrobe: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No items yet. Tap + to add your first item.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return ClothingItemCard(
                item: item,
                onArchive: () => ref
                    .read(wardrobeItemsProvider.notifier)
                    .archiveItem(item.id),
              );
            },
          );
        },
      ),
    );
  }
}
