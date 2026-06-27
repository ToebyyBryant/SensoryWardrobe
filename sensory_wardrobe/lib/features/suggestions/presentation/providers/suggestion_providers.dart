import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/suggestion_engine.dart';
import '../../../wardrobe/data/models/clothing_item_model.dart';
import '../../../wardrobe/presentation/providers/wardrobe_providers.dart';
import '../../../outfit_log/presentation/providers/outfit_log_providers.dart';
import '../../../weather/presentation/providers/weather_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Engine ────────────────────────────────────────────────────────────────────

final suggestionEngineProvider = Provider<SuggestionEngine>((ref) {
  return SuggestionEngine(
    wardrobeRepo: ref.watch(wardrobeRepositoryProvider),
    outfitLogRepo: ref.watch(outfitLogRepositoryProvider),
  );
});

// ── Suggestions based on current weather ─────────────────────────────────────

final suggestionsProvider =
    FutureProvider<List<ClothingItemModel>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return [];

  final weatherAsync = ref.watch(currentWeatherProvider);
  final weather = weatherAsync.valueOrNull;
  if (weather == null) return [];

  return ref.watch(suggestionEngineProvider).getSuggestions(
        userId: profile.id,
        weather: weather,
      );
});

// ── Top suggestion (just the first result) ────────────────────────────────────

final topSuggestionProvider = FutureProvider<ClothingItemModel?>((ref) async {
  final suggestions = await ref.watch(suggestionsProvider.future);
  return suggestions.isEmpty ? null : suggestions.first;
});
