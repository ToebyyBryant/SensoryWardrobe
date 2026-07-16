import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../providers/history_providers.dart';

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
        bottomNavigationBar: const AppBottomNav(currentIndex: 4),
        body: const TabBarView(
          children: [
            _OutfitHistoryTab(),
            _ComfortTrendsTab(),
          ],
        ),
      ),
    );
  }
}

class _OutfitHistoryTab extends ConsumerWidget {
  const _OutfitHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(outfitHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load history: $e')),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No outfit logs yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rating = entry.rating?.overallScore;
            return Card(
              child: ListTile(
                title: Text(entry.log.loggedDate.toLocal().toString().split(' ').first),
                subtitle: Text('Items: ${entry.log.itemIds.length}'),
                trailing: Text(rating == null ? 'Not rated' : 'Rating: $rating/5'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ComfortTrendsTab extends ConsumerWidget {
  const _ComfortTrendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(comfortStatsProvider);
    final trendAsync = ref.watch(comfortTrendProvider);

    return trendAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load trends: $e')),
      data: (points) {
        return statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load stats: $e')),
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Overall Average Comfort'),
                    subtitle: Text(stats.overallAverage.toStringAsFixed(2)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Total Outfit Logs'),
                    trailing: Text('${stats.totalLogs}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Total Ratings'),
                    trailing: Text('${stats.totalRatings}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('High Comfort Days (>= 4)'),
                    trailing: Text('${stats.highComfortDays}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Low Comfort Days (<= 2)'),
                    trailing: Text('${stats.lowComfortDays}'),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Daily points: ${points.length}'),
              ],
            );
          },
        );
      },
    );
  }
}
