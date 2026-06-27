import '../../../wardrobe/data/models/clothing_item_model.dart';
import '../../../weather/data/models/weather_snapshot_model.dart';
import '../../../outfit_log/data/repositories/outfit_log_repository.dart';
import '../../../wardrobe/data/repositories/wardrobe_repository.dart';

/// P5.0 — Generate Smart Suggestions
///
/// Algorithm:
/// 1. Get current weather snapshot's temperature range
/// 2. Filter wardrobe items by appropriate warmth level
/// 3. Score each item using historical comfort ratings
/// 4. Return top-rated combinations
class SuggestionEngine {
  final WardrobeRepository _wardrobeRepo;
  final OutfitLogRepository _outfitLogRepo;

  SuggestionEngine({
    required WardrobeRepository wardrobeRepo,
    required OutfitLogRepository outfitLogRepo,
  })  : _wardrobeRepo = wardrobeRepo,
        _outfitLogRepo = outfitLogRepo;

  /// Returns a list of suggested clothing items for the given weather.
  Future<List<ClothingItemModel>> getSuggestions({
    required String userId,
    required WeatherSnapshotModel weather,
  }) async {
    // 1. Determine target warmth level from temperature
    final targetWarmth = _tempToWarmthLevel(weather.temperatureC);

    // 2. Get all wardrobe items
    final allItems = await _wardrobeRepo.getItemsForUser(userId);

    // 3. Get historical comfort scores
    final itemScores =
        await _outfitLogRepo.getAverageScorePerItem(userId);

    // 4. Filter items that match warmth range (±1 level)
    final candidates = allItems.where((item) {
      if (item.warmthLevel == null) return true;
      return (item.warmthLevel! - targetWarmth).abs() <= 1;
    }).toList();

    // 5. Sort by comfort score descending (unknown = neutral 3.0)
    candidates.sort((a, b) {
      final scoreA = itemScores[a.id] ?? 3.0;
      final scoreB = itemScores[b.id] ?? 3.0;
      return scoreB.compareTo(scoreA);
    });

    return candidates;
  }

  /// Maps temperature (°C) to a 1–5 warmth level.
  int _tempToWarmthLevel(double tempC) {
    if (tempC <= 0) return 5; // very cold
    if (tempC <= 10) return 4; // cold
    if (tempC <= 18) return 3; // mild
    if (tempC <= 25) return 2; // warm
    return 1; // hot
  }
}
