import 'package:flutter_test/flutter_test.dart';

import 'package:sensory_wardrobe/features/outfit_log/data/repositories/outfit_log_repository.dart';
import 'package:sensory_wardrobe/features/suggestions/data/services/suggestion_engine.dart';
import 'package:sensory_wardrobe/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:sensory_wardrobe/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:sensory_wardrobe/features/weather/data/models/weather_snapshot_model.dart';

class _FakeWardrobeRepository extends WardrobeRepository {
  _FakeWardrobeRepository(this.items);

  final List<ClothingItemModel> items;

  @override
  Future<List<ClothingItemModel>> getItemsForUser(String userId) async {
    return items.where((item) => item.userId == userId).toList();
  }
}

class _FakeOutfitLogRepository extends OutfitLogRepository {
  _FakeOutfitLogRepository(this.scores);

  final Map<String, double> scores;

  @override
  Future<Map<String, double>> getAverageScorePerItem(String userId) async {
    return scores;
  }
}

void main() {
  group('SuggestionEngine', () {
    test('filters by warmth target and sorts by comfort score', () async {
      final items = [
        ClothingItemModel(
          id: 'tee',
          userId: 'u1',
          name: 'Soft Tee',
          category: 'Top',
          warmthLevel: 2,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        ClothingItemModel(
          id: 'hoodie',
          userId: 'u1',
          name: 'Hoodie',
          category: 'Top',
          warmthLevel: 3,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        ClothingItemModel(
          id: 'parka',
          userId: 'u1',
          name: 'Parka',
          category: 'Jacket / Outerwear',
          warmthLevel: 5,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final engine = SuggestionEngine(
        wardrobeRepo: _FakeWardrobeRepository(items),
        outfitLogRepo: _FakeOutfitLogRepository(
          {
            'tee': 4.4,
            'hoodie': 3.2,
            'parka': 5.0,
          },
        ),
      );

      final warmWeather = WeatherSnapshotModel(
        id: 'w1',
        temperatureC: 24,
        feelsLikeC: 25,
        humidity: 40,
        condition: 'clear sky',
        windSpeedKph: 10,
        fetchedAt: DateTime(2026, 7, 15),
      );

      final result = await engine.getSuggestions(userId: 'u1', weather: warmWeather);

      expect(result.map((i) => i.id), ['tee', 'hoodie']);
    });

    test('uses neutral score for unseen items', () async {
      final items = [
        ClothingItemModel(
          id: 'known',
          userId: 'u1',
          name: 'Known',
          category: 'Top',
          warmthLevel: 3,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        ClothingItemModel(
          id: 'new',
          userId: 'u1',
          name: 'New Item',
          category: 'Top',
          warmthLevel: 3,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final engine = SuggestionEngine(
        wardrobeRepo: _FakeWardrobeRepository(items),
        outfitLogRepo: _FakeOutfitLogRepository({'known': 2.5}),
      );

      final mildWeather = WeatherSnapshotModel(
        id: 'w2',
        temperatureC: 18,
        feelsLikeC: 18,
        humidity: 55,
        condition: 'cloudy',
        windSpeedKph: 8,
        fetchedAt: DateTime(2026, 7, 15),
      );

      final result = await engine.getSuggestions(userId: 'u1', weather: mildWeather);

      expect(result.first.id, 'new');
      expect(result.last.id, 'known');
    });
  });
}
