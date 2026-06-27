import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../outfit_log/data/models/outfit_log_model.dart';
import '../../../outfit_log/data/models/comfort_rating_model.dart';
import '../../../outfit_log/presentation/providers/outfit_log_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Full history list (logs + their ratings zipped) ──────────────────────────

class OutfitHistoryEntry {
  final OutfitLogModel log;
  final ComfortRatingModel? rating;

  const OutfitHistoryEntry({required this.log, this.rating});
}

final outfitHistoryProvider =
    FutureProvider<List<OutfitHistoryEntry>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return [];

  final repo = ref.watch(outfitLogRepositoryProvider);
  final logs = await repo.getLogsForUser(profile.id);

  // Fetch rating for each log in parallel
  final entries = await Future.wait(
    logs.map((log) async {
      final rating = await repo.getRatingForLog(log.id);
      return OutfitHistoryEntry(log: log, rating: rating);
    }),
  );

  return entries;
});

// ── Comfort trend: average overall score per day ──────────────────────────────

class DailyComfortPoint {
  final DateTime date;
  final double averageScore;

  const DailyComfortPoint({required this.date, required this.averageScore});
}

final comfortTrendProvider =
    FutureProvider<List<DailyComfortPoint>>((ref) async {
  final history = await ref.watch(outfitHistoryProvider.future);

  // Group ratings by date and average them
  final Map<String, List<int>> byDate = {};
  for (final entry in history) {
    if (entry.rating == null) continue;
    final dateKey = entry.log.loggedDate.toIso8601String().substring(0, 10);
    byDate.putIfAbsent(dateKey, () => []).add(entry.rating!.overallScore);
  }

  final points = byDate.entries.map((e) {
    final avg = e.value.reduce((a, b) => a + b) / e.value.length;
    return DailyComfortPoint(
      date: DateTime.parse(e.key),
      averageScore: avg,
    );
  }).toList();

  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
});

// ── Stats summary ─────────────────────────────────────────────────────────────

class ComfortStats {
  final int totalLogs;
  final int totalRatings;
  final double overallAverage;
  final int highComfortDays; // score >= 4
  final int lowComfortDays;  // score <= 2

  const ComfortStats({
    required this.totalLogs,
    required this.totalRatings,
    required this.overallAverage,
    required this.highComfortDays,
    required this.lowComfortDays,
  });
}

final comfortStatsProvider = FutureProvider<ComfortStats>((ref) async {
  final history = await ref.watch(outfitHistoryProvider.future);
  final rated = history.where((e) => e.rating != null).toList();

  if (rated.isEmpty) {
    return ComfortStats(
      totalLogs: history.length,
      totalRatings: 0,
      overallAverage: 0,
      highComfortDays: 0,
      lowComfortDays: 0,
    );
  }

  final scores = rated.map((e) => e.rating!.overallScore).toList();
  final avg = scores.reduce((a, b) => a + b) / scores.length;

  return ComfortStats(
    totalLogs: history.length,
    totalRatings: rated.length,
    overallAverage: avg,
    highComfortDays: scores.where((s) => s >= 4).length,
    lowComfortDays: scores.where((s) => s <= 2).length,
  );
});
