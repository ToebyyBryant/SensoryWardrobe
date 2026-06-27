import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// P2.0 — Wardrobe Catalog Screen
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add clothing item',
            onPressed: () => context.go(AppRoutes.addClothingItem),
          ),
        ],
      ),
      body: const Center(
        // TODO: Replace with wardrobe item list from provider
        child: Text('Wardrobe catalog coming soon'),
      ),
    );
  }
}
