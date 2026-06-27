import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/weather/data/models/weather_snapshot_model.dart';

/// Displays a compact weather summary card.
class WeatherCard extends StatelessWidget {
  final WeatherSnapshotModel weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon via OpenWeatherMap CDN
            if (weather.conditionIcon != null)
              Image.network(
                'https://openweathermap.org/img/wn/${weather.conditionIcon}@2x.png',
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.wb_cloudy_outlined, size: 48),
              )
            else
              const Icon(Icons.wb_sunny_outlined,
                  size: 48, color: AppColors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.locationName ?? 'Current Location',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${weather.temperatureC.toStringAsFixed(1)}°C  •  ${weather.condition}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Feels like ${weather.feelsLikeC.toStringAsFixed(1)}°C  •  ${weather.humidity}% humidity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
