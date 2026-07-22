import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'No outfit logs yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Log your first outfit to start tracking comfort.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rating = entry.rating?.overallScore;
            final dateStr = DateFormat.yMMMd()
                .format(entry.log.loggedDate.toLocal());

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: rating != null
                      ? _scoreColor(rating)
                      : AppColors.cardBorder,
                  child: Text(
                    rating?.toString() ?? '—',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(dateStr),
                subtitle: Text(
                  '${entry.log.itemIds.length} items'
                  '${entry.log.notes != null && entry.log.notes!.isNotEmpty ? ' • ${entry.log.notes}' : ''}',
                ),
                trailing: rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: AppColors.teal,
                          ),
                        ),
                      )
                    : const Text(
                        'Not rated',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Color _scoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score == 3) return Colors.orange;
    return Colors.red;
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
          error: (e, _) => Center(child: Text('$e')),
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats summary cards
                _StatsRow(stats: stats),
                const SizedBox(height: 24),

                // Chart
                Text(
                  'Comfort Over Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (points.length < 2)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Rate at least 2 outfits to see a trend chart.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 220,
                    child: _ComfortChart(points: points),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ComfortStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Average',
            value: stats.totalRatings == 0
                ? '—'
                : stats.overallAverage.toStringAsFixed(1),
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Outfits',
            value: '${stats.totalLogs}',
            icon: Icons.checkroom_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Great Days',
            value: '${stats.highComfortDays}',
            icon: Icons.sentiment_very_satisfied_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.teal, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComfortChart extends StatelessWidget {
  final List<DailyComfortPoint> points;
  const _ComfortChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.averageScore);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0.5,
        maxY: 5.5,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardBorder,
            strokeWidth: 0.5,
          ),
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                if (value < 1 || value > 5) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (points.length > 7) ? 2 : 1,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat.Md().format(points[idx].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.teal,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.teal.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final date = idx < points.length
                    ? DateFormat.MMMd().format(points[idx].date)
                    : '';
                return LineTooltipItem(
                  '$date\n${spot.y.toStringAsFixed(1)}/5',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
