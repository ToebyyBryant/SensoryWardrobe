import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/weather_snapshot_model.dart';
import '../../data/repositories/weather_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

// ── Current weather (fetched on demand) ──────────────────────────────────────

final currentWeatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherSnapshotModel?>>(
  (ref) => WeatherNotifier(ref.watch(weatherRepositoryProvider)),
);

class WeatherNotifier
    extends StateNotifier<AsyncValue<WeatherSnapshotModel?>> {
  final WeatherRepository _repo;

  WeatherNotifier(this._repo) : super(const AsyncValue.loading()) {
    _loadCached();
  }

  /// On startup, show the last cached snapshot immediately while we
  /// decide whether to fetch fresh data.
  Future<void> _loadCached() async {
    final cached = await _repo.getLatestCachedSnapshot();
    if (mounted) state = AsyncValue.data(cached);
  }

  /// Requests device location then calls the weather API.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final snapshot = await _repo.fetchCurrentWeather(
        lat: position.latitude,
        lon: position.longitude,
      );
      if (mounted) state = AsyncValue.data(snapshot);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}

// ── Snapshot by ID (used when loading outfit log detail) ─────────────────────

final weatherSnapshotByIdProvider =
    FutureProvider.family<WeatherSnapshotModel?, String>(
  (ref, id) => ref.watch(weatherRepositoryProvider).getSnapshotById(id),
);
