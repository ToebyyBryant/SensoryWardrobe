import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// P6.0 — View History & Trends
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History & Trends'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Outfit Log'),
              Tab(text: 'Comfort Trends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // TODO: OutfitLogListView
            Center(child: Text('Outfit log history coming soon')),
            // TODO: ComfortTrendChart
            Center(child: Text('Comfort trend charts coming soon')),
          ],
        ),
      ),
    );
  }
}
