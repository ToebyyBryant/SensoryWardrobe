import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/comfort_rating_model.dart';
import '../../data/models/outfit_log_model.dart';
import '../../data/repositories/outfit_log_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final outfitLogRepositoryProvider = Provider<OutfitLogRepository>((ref) {
  return OutfitLogRepository();
});

// ── All logs for active user ──────────────────────────────────────────────────

final outfitLogsProvider =
    StateNotifierProvider<OutfitLogNotifier, AsyncValue<List<OutfitLogModel>>>(
  (ref) {
    final repo = ref.watch(outfitLogRepositoryProvider);
    final profile = ref.watch(activeProfileProvider);
    return OutfitLogNotifier(repo, profile?.id);
  },
);

class OutfitLogNotifier
    extends StateNotifier<AsyncValue<List<OutfitLogModel>>> {
  final OutfitLogRepository _repo;
  final String? _userId;

  OutfitLogNotifier(this._repo, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) load();
  }

  Future<void> load() async {
    if (_userId == null) return;
    try {
      final logs = await _repo.getLogsForUser(_userId!);
      if (mounted) state = AsyncValue.data(logs);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveLog(OutfitLogModel log) async {
    await _repo.saveOutfitLog(log);
    await load();
  }
}

// ── Single log for a specific date ───────────────────────────────────────────

final outfitLogForDateProvider =
    FutureProvider.family<OutfitLogModel?, DateTime>((ref, date) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref
      .watch(outfitLogRepositoryProvider)
      .getLogForDate(profile.id, date);
});

// ── Comfort ratings ───────────────────────────────────────────────────────────

final comfortRatingsProvider =
    StateNotifierProvider<ComfortRatingNotifier,
        AsyncValue<List<ComfortRatingModel>>>(
  (ref) {
    final repo = ref.watch(outfitLogRepositoryProvider);
    final profile = ref.watch(activeProfileProvider);
    return ComfortRatingNotifier(repo, profile?.id);
  },
);

class ComfortRatingNotifier
    extends StateNotifier<AsyncValue<List<ComfortRatingModel>>> {
  final OutfitLogRepository _repo;
  final String? _userId;

  ComfortRatingNotifier(this._repo, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) load();
  }

  Future<void> load() async {
    if (_userId == null) return;
    try {
      final ratings = await _repo.getRatingsForUser(_userId!);
      if (mounted) state = AsyncValue.data(ratings);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveRating(ComfortRatingModel rating) async {
    await _repo.saveComfortRating(rating);
    await load();
  }
}

// ── Rating for a specific outfit log ─────────────────────────────────────────

final comfortRatingForLogProvider =
    FutureProvider.family<ComfortRatingModel?, String>(
  (ref, outfitLogId) => ref
      .watch(outfitLogRepositoryProvider)
      .getRatingForLog(outfitLogId),
);

// ── Average scores per item (feeds suggestion engine) ────────────────────────

final avgComfortScorePerItemProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return {};
  return ref
      .watch(outfitLogRepositoryProvider)
      .getAverageScorePerItem(profile.id);
});
