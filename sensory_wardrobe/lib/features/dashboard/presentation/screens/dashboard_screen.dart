import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../weather/presentation/providers/weather_providers.dart';

/// Home dashboard — weather summary, quick actions, today's suggestion.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensory Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () => ref.read(currentWeatherProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeatherCard(),
              const SizedBox(height: 16),
              _SuggestionCard(),
              const SizedBox(height: 16),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _QuickActionGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return weatherAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 16),
              Text('Fetching weather...'),
            ],
          ),
        ),
      ),
      error: (_, __) => Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off_outlined,
              color: AppColors.textMuted),
          title: const Text('Weather unavailable'),
          subtitle: const Text('Tap to retry'),
          onTap: () =>
              ref.read(currentWeatherProvider.notifier).refresh(),
        ),
      ),
      data: (snapshot) {
        if (snapshot == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_off_outlined),
              title: const Text('No weather data'),
              subtitle: const Text('Tap to fetch'),
              onTap: () =>
                  ref.read(currentWeatherProvider.notifier).refresh(),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined,
                    size: 48, color: AppColors.teal),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.locationName ?? 'Current Location',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${snapshot.temperatureC.toStringAsFixed(1)}°C  •  ${snapshot.condition}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Feels like ${snapshot.feelsLikeC.toStringAsFixed(1)}°C',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.teal),
                  onPressed: () =>
                      ref.read(currentWeatherProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: watch suggestions provider
    return Card(
      color: AppColors.mint.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Top Suggestion",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Loading suggestions...'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('See all suggestions →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.checkroom_outlined, 'Log Outfit', AppRoutes.logOutfit),
      (Icons.star_outline, 'Rate Comfort', AppRoutes.comfortRating),
      (Icons.library_books_outlined, 'My Wardrobe', AppRoutes.wardrobe),
      (Icons.bar_chart_outlined, 'History', AppRoutes.history),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions.map((action) {
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go(action.$3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.$1, size: 32, color: AppColors.teal),
                const SizedBox(height: 8),
                Text(action.$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
