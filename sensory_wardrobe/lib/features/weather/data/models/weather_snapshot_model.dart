import 'package:flutter/foundation.dart';

/// DS5: Weather Snapshot
/// Cached weather data tied to a date/location.
@immutable
class WeatherSnapshotModel {
  final String id;
  final double? locationLat;
  final double? locationLon;
  final String? locationName;
  final double temperatureC;
  final double feelsLikeC;
  final int humidity;
  final String condition;
  final String? conditionIcon;
  final double windSpeedKph;
  final DateTime fetchedAt;

  const WeatherSnapshotModel({
    required this.id,
    this.locationLat,
    this.locationLon,
    this.locationName,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.condition,
    this.conditionIcon,
    required this.windSpeedKph,
    required this.fetchedAt,
  });

  /// Construct from Open-Meteo API response JSON.
  ///
  /// Open-Meteo current_weather response shape:
  /// {
  ///   "current_weather": {
  ///     "temperature": 22.3,
  ///     "windspeed": 11.5,
  ///     "weathercode": 2,
  ///     "time": "2026-06-15T14:00"
  ///   },
  ///   "hourly": {
  ///     "relative_humidity_2m": [65, 64, ...],
  ///     "apparent_temperature": [20.1, 19.8, ...]
  ///   }
  /// }
  factory WeatherSnapshotModel.fromOpenMeteoJson(
    Map<String, dynamic> json,
    double lat,
    double lon,
  ) {
    final current = json['current_weather'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>?;

    // Get current hour index for hourly data
    final now = DateTime.now();
    final hourIndex = now.hour;

    // Humidity from hourly data (current hour)
    final humidityList = hourly?['relative_humidity_2m'] as List?;
    final humidity = (humidityList != null && hourIndex < humidityList.length)
        ? (humidityList[hourIndex] as num).toInt()
        : 0;

    // Feels-like from hourly apparent_temperature
    final feelsLikeList = hourly?['apparent_temperature'] as List?;
    final feelsLike = (feelsLikeList != null && hourIndex < feelsLikeList.length)
        ? (feelsLikeList[hourIndex] as num).toDouble()
        : (current['temperature'] as num).toDouble();

    final weatherCode = (current['weathercode'] as num).toInt();

    return WeatherSnapshotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationLat: lat,
      locationLon: lon,
      locationName: null, // Open-Meteo doesn't return city name
      temperatureC: (current['temperature'] as num).toDouble(),
      feelsLikeC: feelsLike,
      humidity: humidity,
      condition: _weatherCodeToCondition(weatherCode),
      conditionIcon: _weatherCodeToIcon(weatherCode),
      windSpeedKph: (current['windspeed'] as num).toDouble(),
      fetchedAt: DateTime.now(),
    );
  }

  /// Legacy: Construct from OpenWeatherMap API response JSON.
  factory WeatherSnapshotModel.fromApiJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather =
        (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final coord = json['coord'] as Map<String, dynamic>?;

    return WeatherSnapshotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationLat: (coord?['lat'] as num?)?.toDouble(),
      locationLon: (coord?['lon'] as num?)?.toDouble(),
      locationName: json['name'] as String?,
      temperatureC: (main['temp'] as num).toDouble(),
      feelsLikeC: (main['feels_like'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      condition: weather['description'] as String,
      conditionIcon: weather['icon'] as String?,
      windSpeedKph: ((wind['speed'] as num).toDouble() * 3.6),
      fetchedAt: DateTime.now(),
    );
  }

  factory WeatherSnapshotModel.fromMap(Map<String, dynamic> map) {
    return WeatherSnapshotModel(
      id: map['id'] as String,
      locationLat: map['location_lat'] as double?,
      locationLon: map['location_lon'] as double?,
      locationName: map['location_name'] as String?,
      temperatureC: (map['temperature_c'] as num).toDouble(),
      feelsLikeC: (map['feels_like_c'] as num).toDouble(),
      humidity: map['humidity'] as int,
      condition: map['condition'] as String,
      conditionIcon: map['condition_icon'] as String?,
      windSpeedKph: (map['wind_speed_kph'] as num).toDouble(),
      fetchedAt: DateTime.parse(map['fetched_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'location_lat': locationLat,
        'location_lon': locationLon,
        'location_name': locationName,
        'temperature_c': temperatureC,
        'feels_like_c': feelsLikeC,
        'humidity': humidity,
        'condition': condition,
        'condition_icon': conditionIcon,
        'wind_speed_kph': windSpeedKph,
        'fetched_at': fetchedAt.toIso8601String(),
      };

  /// Map WMO weather codes to human-readable conditions.
  /// https://open-meteo.com/en/docs#weathervariables
  static String _weatherCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Map WMO weather codes to material icon names for UI display.
  static String _weatherCodeToIcon(int code) {
    if (code == 0 || code == 1) return 'sunny';
    if (code == 2) return 'partly_cloudy';
    if (code == 3) return 'cloudy';
    if (code == 45 || code == 48) return 'foggy';
    if (code >= 51 && code <= 67) return 'rainy';
    if (code >= 71 && code <= 86) return 'snowy';
    if (code >= 95) return 'thunderstorm';
    return 'cloudy';
  }
}
