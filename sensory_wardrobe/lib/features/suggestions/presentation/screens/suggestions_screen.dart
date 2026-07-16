import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/clothing_item_card.dart';
import '../providers/suggestion_providers.dart';

/// P5.0 — Smart Suggestions Screen
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Suggestions')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load suggestions: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No suggestions yet. Add wardrobe items and weather.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ClothingItemCard(item: items[index]);
            },
          );
        },
      ),
    );
  }
}
