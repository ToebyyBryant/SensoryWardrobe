import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/weather_snapshot_model.dart';

/// P3.0 — Fetch & Store Weather Data
/// Calls OpenWeatherMap API and caches results in DS5.
class WeatherRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _db;
  final FlutterSecureStorage _secureStorage;

  WeatherRepository({
    ApiClient? apiClient,
    DatabaseHelper? db,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient ??
            ApiClient(baseUrl: AppConstants.weatherApiBaseUrl),
        _db = db ?? DatabaseHelper(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Fetch current weather for coordinates, cache and return snapshot.
  Future<WeatherSnapshotModel> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final apiKey = await _secureStorage.read(
      key: AppConstants.weatherApiKeyEnvVar,
    );

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Weather API key not configured. Set it in Settings.');
    }

    final data = await _apiClient.get(
      '/weather',
      queryParams: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );

    final snapshot = WeatherSnapshotModel.fromApiJson(data);
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
