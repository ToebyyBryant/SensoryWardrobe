import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// P4.0 — Log today's outfit selection.
class LogOutfitScreen extends ConsumerWidget {
  const LogOutfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Outfit")),
      body: const Center(
        // TODO: Outfit selection from wardrobe catalog + weather context
        child: Text("Log outfit screen coming soon"),
      ),
    );
  }
}
