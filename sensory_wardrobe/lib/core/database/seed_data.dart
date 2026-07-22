import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';

/// Seeds example data for new users so they can see what the app
/// looks like with real content. Users can delete these items at any time.
class SeedData {
  static const _seedCompleteKey = 'seed_data_inserted';

  /// Call after user registers. Only seeds once per device.
  static Future<void> seedIfNeeded(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seedCompleteKey) ?? false) return;

    final db = await DatabaseHelper().database;
    await _seedWardrobeItems(db, userId);
    await _seedWeatherSnapshot(db);
    await _seedOutfitLogs(db, userId);
    await _seedComfortRatings(db, userId);

    await prefs.setBool(_seedCompleteKey, true);
  }

  static Future<void> _seedWardrobeItems(Database db, String userId) async {
    final now = DateTime.now().toIso8601String();

    final items = [
      {
        'id': 'seed_item_1',
        'user_id': userId,
        'name': 'Soft Grey Hoodie',
        'category': 'Top',
        'color': 'Grey',
        'fabric': 'Cotton blend',
        'sensory_tags': '["soft","stretchy","loose-fit","tagless"]',
        'warmth_level': 4,
        'photo_path': null,
        'notes': 'Example item — feel free to delete',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'seed_item_2',
        'user_id': userId,
        'name': 'Navy Joggers',
        'category': 'Bottom',
        'color': 'Navy',
        'fabric': 'French terry',
        'sensory_tags': '["soft","stretchy","loose-fit","breathable"]',
        'warmth_level': 3,
        'photo_path': null,
        'notes': 'Example item — feel free to delete',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'seed_item_3',
        'user_id': userId,
        'name': 'White Cotton Tee',
        'category': 'Top',
        'color': 'White',
        'fabric': '100% cotton',
        'sensory_tags': '["soft","lightweight","breathable","seamless"]',
        'warmth_level': 2,
        'photo_path': null,
        'notes': 'Example item — feel free to delete',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'seed_item_4',
        'user_id': userId,
        'name': 'Seamless Ankle Socks',
        'category': 'Socks',
        'color': 'Black',
        'fabric': 'Bamboo',
        'sensory_tags': '["seamless","soft","moisture-wicking","lightweight"]',
        'warmth_level': 1,
        'photo_path': null,
        'notes': 'Example item — feel free to delete',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'seed_item_5',
        'user_id': userId,
        'name': 'Fleece-Lined Jacket',
        'category': 'Jacket / Outerwear',
        'color': 'Green',
        'fabric': 'Polyester fleece',
        'sensory_tags': '["soft","heavyweight","tagless"]',
        'warmth_level': 5,
        'photo_path': null,
        'notes': 'Example item — feel free to delete',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final item in items) {
      await db.insert(
        'wardrobe_items',
        item,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _seedWeatherSnapshot(Database db) async {
    await db.insert(
      'weather_snapshots',
      {
        'id': 'seed_weather_1',
        'location_lat': 39.7392,
        'location_lon': -104.9903,
        'location_name': 'Denver',
        'temperature_c': 18.5,
        'feels_like_c': 17.2,
        'humidity': 42,
        'condition': 'Partly cloudy',
        'condition_icon': 'partly_cloudy',
        'wind_speed_kph': 12.0,
        'fetched_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> _seedOutfitLogs(Database db, String userId) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

    final logs = [
      {
        'id': 'seed_log_1',
        'user_id': userId,
        'logged_date': twoDaysAgo.toIso8601String().substring(0, 10),
        'item_ids': '["seed_item_1","seed_item_2","seed_item_4"]',
        'weather_snapshot_id': 'seed_weather_1',
        'notes': 'Cozy day at home',
        'created_at': twoDaysAgo.toIso8601String(),
      },
      {
        'id': 'seed_log_2',
        'user_id': userId,
        'logged_date': yesterday.toIso8601String().substring(0, 10),
        'item_ids': '["seed_item_3","seed_item_2","seed_item_4"]',
        'weather_snapshot_id': 'seed_weather_1',
        'notes': 'Warm enough for a tee',
        'created_at': yesterday.toIso8601String(),
      },
    ];

    for (final log in logs) {
      await db.insert(
        'outfit_logs',
        log,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _seedComfortRatings(Database db, String userId) async {
    final ratings = [
      {
        'id': 'seed_rating_1',
        'outfit_log_id': 'seed_log_1',
        'user_id': userId,
        'overall_score': 5,
        'texture_score': 5,
        'pressure_score': 4,
        'temperature_score': 5,
        'notes': null,
        'rated_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 'seed_rating_2',
        'outfit_log_id': 'seed_log_2',
        'user_id': userId,
        'overall_score': 4,
        'texture_score': 5,
        'pressure_score': 4,
        'temperature_score': 3,
        'notes': null,
        'rated_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
    ];

    for (final rating in ratings) {
      await db.insert(
        'comfort_ratings',
        rating,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
