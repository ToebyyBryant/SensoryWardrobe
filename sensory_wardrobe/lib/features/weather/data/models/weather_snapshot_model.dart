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

  /// Construct from OpenWeatherMap API response JSON.
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
}
