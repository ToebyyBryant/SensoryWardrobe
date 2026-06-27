import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// P5.0 — Smart Suggestions Screen
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Suggestions')),
      body: const Center(
        // TODO: Load suggestions from suggestion engine provider
        child: Text('Smart suggestions coming soon'),
      ),
    );
  }
}
