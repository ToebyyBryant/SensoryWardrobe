import 'package:sqflite/sqflite.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/weather_snapshot_model.dart';

/// P3.0 — Fetch & Store Weather Data
/// Calls Open-Meteo API (free, no key required) and caches results in DS5.
class WeatherRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _db;

  WeatherRepository({
    ApiClient? apiClient,
    DatabaseHelper? db,
  })  : _apiClient = apiClient ??
            ApiClient(baseUrl: AppConstants.weatherApiBaseUrl),
        _db = db ?? DatabaseHelper();

  /// Fetch current weather for coordinates, cache and return snapshot.
  Future<WeatherSnapshotModel> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final data = await _apiClient.get(
      '/forecast',
      queryParams: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current_weather': 'true',
        'hourly': 'relative_humidity_2m,apparent_temperature',
        'forecast_days': '1',
      },
    );

    final snapshot = WeatherSnapshotModel.fromOpenMeteoJson(data, lat, lon);
    await _cacheSnapshot(snapshot);
    return snapshot;
  }

  /// Returns the most recent cached snapshot (avoids redundant API calls).
  Future<WeatherSnapshotModel?> getLatestCachedSnapshot() async {
    final db = await _db.database;
    final rows = await db.query(
      'weather_snapshots',
      orderBy: 'fetched_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WeatherSnapshotModel.fromMap(rows.first);
  }

  Future<WeatherSnapshotModel?> getSnapshotById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'weather_snapshots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return WeatherSnapshotModel.fromMap(rows.first);
  }

  Future<void> _cacheSnapshot(WeatherSnapshotModel snapshot) async {
    final db = await _db.database;
    await db.insert(
      'weather_snapshots',
      snapshot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
