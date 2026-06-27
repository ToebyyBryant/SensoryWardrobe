# Design Document: Full App Completion

## Overview

This document details the architecture and design for completing the Sensory Wardrobe Flutter application. It covers all remaining unimplemented screens, wiring existing backend services to their UI layers, adding authentication guards, onboarding, multi-profile switching, notification scheduling, admin features, and image display integration.

The design builds upon the existing clean architecture with feature-based folders, Riverpod StateNotifier pattern, GoRouter navigation, and the already-implemented data layer (DatabaseHelper, repositories, services).

## Architecture

The application follows a **layered clean architecture** with feature-based modularization:

```
lib/
├── core/                          # Cross-cutting concerns
│   ├── database/                  # DatabaseHelper (DS1–DS5)
│   ├── router/                    # GoRouter + Auth Guard
│   ├── theme/                     # AppTheme, AppColors
│   ├── constants/                 # AppConstants
│   ├── network/                   # ApiClient
│   └── error/                     # AppException hierarchy
├── features/
│   ├── auth/                      # P1.0 Authentication & Profiles
│   ├── wardrobe/                  # P2.0 Wardrobe Catalog
│   ├── weather/                   # P3.0 Weather Data
│   ├── outfit_log/                # P4.0 Outfit Logging & Comfort Rating
│   ├── suggestions/               # P5.0 Smart Suggestions
│   ├── history/                   # P6.0 History & Trends
│   ├── notifications/             # P7.0 Notifications & Reminders
│   ├── backup/                    # P8.0 Backup & Restore
│   ├── admin/                     # P9.0 Admin System Management
│   ├── onboarding/                # Onboarding Flow
│   ├── profile/                   # Profile Screen
│   └── settings/                  # Settings Screen
└── shared/widgets/                # Reusable UI components
```

Each feature follows the internal structure:
```
feature_name/
├── data/
│   ├── models/          # Immutable data classes with fromMap/toMap
│   ├── repositories/    # Database/API access
│   └── services/        # Business logic (e.g., SuggestionEngine)
└── presentation/
    ├── screens/         # Full-page widgets
    ├── providers/       # Riverpod StateNotifier providers
    └── widgets/         # Feature-specific widgets
```

## Components and Interfaces

### 1. Wardrobe List Screen (Requirement 1)

**File:** `lib/features/wardrobe/presentation/screens/wardrobe_screen.dart`

Replaces the existing placeholder with a fully functional list view.

**Provider:** `WardrobeNotifier` (StateNotifier)

```dart
// lib/features/wardrobe/presentation/providers/wardrobe_providers.dart

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});

final wardrobeListProvider = StateNotifierProvider<WardrobeNotifier,
    AsyncValue<List<ClothingItemModel>>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return WardrobeNotifier(repo, userId);
});

class WardrobeNotifier
    extends StateNotifier<AsyncValue<List<ClothingItemModel>>> {
  final WardrobeRepository _repo;
  final String _userId;

  WardrobeNotifier(this._repo, this._userId)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getItemsForUser(_userId);
      if (mounted) state = AsyncValue.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveItem(String itemId) async {
    await _repo.archiveItem(itemId);
    await loadItems();
  }
}
```

**Filter Provider:**

```dart
final wardrobeFilterProvider =
    StateProvider<WardrobeFilter>((ref) => const WardrobeFilter());

class WardrobeFilter {
  final String? category;
  final String? fabric;
  final String? sensoryTag;
  const WardrobeFilter({this.category, this.fabric, this.sensoryTag});
}

final filteredWardrobeProvider =
    Provider<AsyncValue<List<ClothingItemModel>>>((ref) {
  final items = ref.watch(wardrobeListProvider);
  final filter = ref.watch(wardrobeFilterProvider);
  return items.whenData((list) => list.where((item) {
    if (filter.category != null && item.category != filter.category) return false;
    if (filter.fabric != null && item.fabric != filter.fabric) return false;
    if (filter.sensoryTag != null &&
        !item.sensoryTags.contains(filter.sensoryTag)) return false;
    return true;
  }).toList());
});
```

### 2. Add/Edit Clothing Item with Photo Integration (Requirement 2)

**File:** `lib/features/wardrobe/presentation/screens/add_clothing_item_screen.dart`

The existing screen gains form validation, sensory tag selection, and image_picker integration.

**Provider:**

```dart
// lib/features/wardrobe/presentation/providers/clothing_item_form_provider.dart

class ClothingItemFormState {
  final String name;
  final String category;
  final String? color;
  final String? fabric;
  final List<String> sensoryTags;
  final int? warmthLevel;
  final String? photoPath;
  final String? notes;
  final bool isSubmitting;
  final String? errorMessage;

  const ClothingItemFormState({
    this.name = '',
    this.category = '',
    this.color,
    this.fabric,
    this.sensoryTags = const [],
    this.warmthLevel,
    this.photoPath,
    this.notes,
    this.isSubmitting = false,
    this.errorMessage,
  });

  bool get isValid => name.trim().isNotEmpty && category.trim().isNotEmpty;
}

class ClothingItemFormNotifier extends StateNotifier<ClothingItemFormState> {
  final WardrobeRepository _repo;

  ClothingItemFormNotifier(this._repo)
      : super(const ClothingItemFormState());

  void setName(String v) => state = ClothingItemFormState(/* ... */);
  void setPhotoPath(String? path) => state = /* updated state */;

  Future<bool> submit(String userId, {String? existingId}) async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Name and category are required');
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final item = ClothingItemModel(
        id: existingId ?? _generateId(),
        userId: userId,
        name: state.name.trim(),
        category: state.category.trim(),
        /* ... remaining fields ... */
      );
      if (existingId != null) {
        await _repo.updateItem(item);
      } else {
        await _repo.addItem(item);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}
```

**Image Picker Integration:**

```dart
Future<void> pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: source, maxWidth: 800);
  if (picked != null) {
    setPhotoPath(picked.path);
  }
}
```

### 3. Log Outfit Screen (Requirement 3)

**File:** `lib/features/outfit_log/presentation/screens/log_outfit_screen.dart`

The existing screen placeholder is replaced with multi-select item picking and outfit log creation.

**Provider:**

```dart
// lib/features/outfit_log/presentation/providers/outfit_log_providers.dart

class OutfitLogFormState {
  final Set<String> selectedItemIds;
  final String? notes;
  final bool isSubmitting;
  final String? errorMessage;

  const OutfitLogFormState({
    this.selectedItemIds = const {},
    this.notes,
    this.isSubmitting = false,
    this.errorMessage,
  });
}

class OutfitLogFormNotifier extends StateNotifier<OutfitLogFormState> {
  final OutfitLogRepository _outfitLogRepo;
  final WeatherRepository _weatherRepo;

  OutfitLogFormNotifier(this._outfitLogRepo, this._weatherRepo)
      : super(const OutfitLogFormState());

  void toggleItem(String id) { /* toggle in selectedItemIds */ }
  void setNotes(String? notes) { /* update notes */ }

  Future<String?> submit(String userId) async {
    if (state.selectedItemIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Select at least one item');
      return null;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      // Ensure weather snapshot exists
      var weather = await _weatherRepo.getLatestCachedSnapshot();
      if (weather == null) {
        // Fetch fresh weather (triggers location + API call)
        weather = await _fetchFreshWeather();
      }

      final log = OutfitLogModel(
        id: _generateId(),
        userId: userId,
        loggedDate: DateTime.now(),
        itemIds: state.selectedItemIds.toList(),
        weatherSnapshotId: weather?.id,
        notes: state.notes,
        createdAt: DateTime.now(),
      );
      await _outfitLogRepo.saveOutfitLog(log);
      return log.id; // Used for navigation to comfort rating
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }
}
```

### 4. Comfort Rating Save Wiring (Requirement 4)

**File:** `lib/features/outfit_log/presentation/screens/comfort_rating_screen.dart`

Wires the existing `ComfortRatingScreen` UI to the `OutfitLogRepository.saveComfortRating` method.

**Provider:**

```dart
// lib/features/outfit_log/presentation/providers/comfort_rating_provider.dart

class ComfortRatingNotifier extends StateNotifier<AsyncValue<void>> {
  final OutfitLogRepository _repo;

  ComfortRatingNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> saveRating({
    required String outfitLogId,
    required String userId,
    required int overallScore,
    int? textureScore,
    int? pressureScore,
    int? temperatureScore,
    String? notes,
  }) async {
    // Validate score range
    if (overallScore < 1 || overallScore > 5) return false;

    state = const AsyncValue.loading();
    try {
      final rating = ComfortRatingModel(
        id: _generateId(),
        outfitLogId: outfitLogId,
        userId: userId,
        overallScore: overallScore,
        textureScore: textureScore,
        pressureScore: pressureScore,
        temperatureScore: temperatureScore,
        notes: notes,
        ratedAt: DateTime.now(),
      );
      await _repo.saveComfortRating(rating);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
```

The screen's `_saveRating()` method calls the provider, shows a SnackBar on success, and navigates to Dashboard. On failure, it shows an error SnackBar and retains form state.

### 5. Suggestions Screen (Requirement 5)

**File:** `lib/features/suggestions/presentation/screens/suggestions_screen.dart`

Replaces the existing placeholder with a list of recommended items from the `SuggestionEngine`.

**Provider:**

```dart
// lib/features/suggestions/presentation/providers/suggestions_providers.dart

final suggestionEngineProvider = Provider<SuggestionEngine>((ref) {
  return SuggestionEngine(
    wardrobeRepo: ref.watch(wardrobeRepositoryProvider),
    outfitLogRepo: ref.watch(outfitLogRepositoryProvider),
  );
});

final suggestionsProvider = StateNotifierProvider<SuggestionsNotifier,
    AsyncValue<List<ClothingItemModel>>>((ref) {
  final engine = ref.watch(suggestionEngineProvider);
  final weather = ref.watch(currentWeatherProvider);
  final userId = ref.watch(currentUserIdProvider);
  return SuggestionsNotifier(engine, weather, userId);
});

class SuggestionsNotifier
    extends StateNotifier<AsyncValue<List<ClothingItemModel>>> {
  final SuggestionEngine _engine;
  final AsyncValue<WeatherSnapshotModel?> _weather;
  final String _userId;

  SuggestionsNotifier(this._engine, this._weather, this._userId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final weatherSnapshot = _weather.valueOrNull;
      final suggestions = await _engine.getSuggestions(
        userId: _userId,
        weather: weatherSnapshot ?? _defaultWeather(),
      );
      if (mounted) state = AsyncValue.data(suggestions);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}
```

**UI Behavior:**
- If fewer than 3 items in wardrobe → show "Add more items" prompt
- If weather unavailable → show suggestions sorted by comfort only with notice banner
- Tapping an item opens a bottom sheet with sensory details and average comfort score

### 6. Dashboard Suggestion Integration (Requirement 6)

**File:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

Wires the `_SuggestionCard` widget to the `suggestionsProvider` to display the top-ranked item.

```dart
class _SuggestionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return suggestionsAsync.when(
      loading: () => /* shimmer card */,
      error: (_, __) => /* error state */,
      data: (items) {
        if (items.isEmpty) {
          return /* prompt: add items or log outfits */;
        }
        final topItem = items.first;
        return Card(
          child: ListTile(
            leading: ClothingThumbnail(photoPath: topItem.photoPath),
            title: Text(topItem.name),
            subtitle: Text('${topItem.category} • ${topItem.fabric ?? ""}'),
            onTap: () => context.go(AppRoutes.suggestions),
          ),
        );
      },
    );
  }
}
```

### 7. History and Trends Display (Requirement 7)

**File:** `lib/features/history/presentation/screens/history_screen.dart`

Replaces the existing placeholder tabs with functional list and chart views.

**Providers:**

```dart
// lib/features/history/presentation/providers/history_providers.dart

final outfitLogListProvider = StateNotifierProvider<OutfitLogListNotifier,
    AsyncValue<List<OutfitLogWithDetails>>>((ref) {
  final repo = ref.watch(outfitLogRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return OutfitLogListNotifier(repo, userId);
});

class OutfitLogWithDetails {
  final OutfitLogModel log;
  final List<ClothingItemModel> items;
  final WeatherSnapshotModel? weather;
  final ComfortRatingModel? rating;
  const OutfitLogWithDetails({...});
}

final historyFilterProvider = StateProvider<HistoryFilter>((ref) => HistoryFilter());

class HistoryFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;
  const HistoryFilter({this.startDate, this.endDate, this.category});
}

final filteredHistoryProvider =
    Provider<AsyncValue<List<OutfitLogWithDetails>>>((ref) {
  final logs = ref.watch(outfitLogListProvider);
  final filter = ref.watch(historyFilterProvider);
  return logs.whenData((list) => list.where((entry) {
    if (filter.startDate != null && entry.log.loggedDate.isBefore(filter.startDate!)) return false;
    if (filter.endDate != null && entry.log.loggedDate.isAfter(filter.endDate!)) return false;
    if (filter.category != null) {
      final hasCategory = entry.items.any((i) => i.category == filter.category);
      if (!hasCategory) return false;
    }
    return true;
  }).toList());
});
```

**Comfort Trends Tab:**
- Uses a simple line chart (via CustomPaint or a lightweight chart package)
- X-axis: date, Y-axis: comfort score (1–5)
- Additional lines for texture, pressure, temperature sub-scores when available

### 8. Authentication Guard (Requirement 8)

**File:** `lib/core/router/app_router.dart`

Adds a `redirect` callback to GoRouter that checks authentication state.

```dart
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.onboarding,
      ].contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthRoute) {
        // Store intended destination for post-login redirect
        return '${AppRoutes.login}?redirect=${state.matchedLocation}';
      }
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.dashboard;
      }
      return null; // No redirect
    },
    routes: [/* ... existing routes ... */],
  );
}
```

**Auth State Provider:**

```dart
// lib/features/auth/presentation/providers/auth_providers.dart

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? '';
});

final activeProfileIdProvider = StateProvider<String>((ref) {
  return ref.watch(currentUserIdProvider);
});
```

**Logout Flow:**
Calls `AuthRepository.logout()`, which triggers `authStateChanges` stream update → GoRouter `redirect` fires → navigates to login with cleared stack.

### 9. Onboarding Flow (Requirement 9)

**New Files:**
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/onboarding/presentation/providers/onboarding_provider.dart`

**Design:** A multi-step PageView with 3 steps:
1. **Welcome + Sensory Preferences** — texture sensitivity, pressure tolerance, temperature preference selectors
2. **Add First Item** — simplified clothing item form (name, category, photo optional)
3. **Completion** — summary and "Get Started" button

**Provider:**

```dart
class OnboardingState {
  final int currentStep;
  final Map<String, dynamic> sensoryPreferences;
  final ClothingItemModel? firstItem;
  final bool isComplete;
  const OnboardingState({...});
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final AuthRepository _authRepo;
  final WardrobeRepository _wardrobeRepo;

  Future<void> complete(String userId) async {
    // Save sensory preferences to user profile
    final profile = await _authRepo.getProfileById(userId);
    if (profile != null) {
      await _authRepo.updateProfile(profile.copyWith(
        sensoryPreferences: state.sensoryPreferences,
      ));
    }
    // Save first item if provided
    if (state.firstItem != null) {
      await _wardrobeRepo.addItem(state.firstItem!);
    }
    // Mark onboarding complete (shared_preferences flag)
  }

  Future<void> skip(String userId) async {
    // Save default sensory preferences
    await _authRepo.updateProfile(/* defaults */);
  }
}
```

**Route:** `/onboarding` added to GoRouter, exempted from auth guard.

### 10. Multi-Profile Switching UI (Requirement 10)

**Files:**
- `lib/features/profile/presentation/widgets/profile_switcher.dart`
- `lib/features/profile/presentation/providers/profile_providers.dart`

**Design:** The `activeProfileIdProvider` StateProvider controls which user's data is loaded across all features. Switching profiles updates this provider, triggering all dependent providers to reload.

```dart
// lib/features/profile/presentation/providers/profile_providers.dart

final dependentProfilesProvider =
    FutureProvider<List<UserProfileModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(authRepositoryProvider).getDependentProfiles(userId);
});

// Switching context: all providers that read activeProfileIdProvider
// will automatically rebuild when this changes.
void switchToProfile(WidgetRef ref, String profileId) {
  ref.read(activeProfileIdProvider.notifier).state = profileId;
}
```

**App Bar Integration:**
When `activeProfileIdProvider != currentUserIdProvider`, the AppBar title shows the dependent's display name with a visual indicator badge.

### 11. Notification Scheduling (Requirement 11)

**File:** `lib/features/notifications/data/services/notification_service.dart`

Completes the existing TODO stubs with timezone-aware scheduling.

```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> scheduleMorningReminder(int hour, int minute) async {
  final scheduledTime = _nextInstanceOfTime(hour, minute);
  await _plugin.zonedSchedule(
    _morningReminderId,
    'Time to log your outfit!',
    'What are you wearing today?',
    scheduledTime,
    _notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: 'route:/log-outfit',
  );
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
```

**Notification Tap Handling:**
On initialization, register an `onDidReceiveNotificationResponse` callback that parses the `payload` string (e.g., `route:/log-outfit`) and calls `GoRouter.go()` to navigate.

### 12. Profile Screen (Requirement 12)

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`

Replaces the existing placeholder with a fully functional profile display and edit form.

**Structure:**
- Display section: avatar, display name, email, sensory preferences summary
- Edit mode: inline editing with save button
- Dependent profiles list (for caregivers): shows profile switcher
- Logout button at bottom

**Provider:**

```dart
final userProfileProvider = FutureProvider<UserProfileModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(authRepositoryProvider).getProfileById(userId);
});
```

### 13. Settings Screen (Requirement 13)

**File:** `lib/features/settings/presentation/screens/settings_screen.dart`

Replaces the existing placeholder with functional settings controls.

**Sections:**
1. **Notifications** — Morning time picker, evening time picker, enable/disable toggles
2. **Backup & Restore** — Manual backup button, restore button, last backup timestamp
3. **Weather API** — API key text field (saved to FlutterSecureStorage)

**Provider:**

```dart
// lib/features/settings/presentation/providers/settings_providers.dart

class SettingsState {
  final TimeOfDay morningReminderTime;
  final TimeOfDay eveningReminderTime;
  final bool morningReminderEnabled;
  final bool eveningReminderEnabled;
  final String? lastBackupTime;
  final bool isBackingUp;
  final bool isRestoring;
  const SettingsState({...});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final NotificationService _notificationService;
  final BackupService _backupService;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  Future<void> setMorningReminder(bool enabled, TimeOfDay time) async {
    if (enabled) {
      await _notificationService.scheduleMorningReminder(time.hour, time.minute);
    } else {
      await _notificationService.cancelAll();
    }
    // Persist preference
    await _prefs.setBool('morning_reminder_enabled', enabled);
    await _prefs.setInt('morning_reminder_hour', time.hour);
    await _prefs.setInt('morning_reminder_minute', time.minute);
  }

  Future<void> triggerBackup() async {
    state = state.copyWith(isBackingUp: true);
    try {
      await _backupService.backupToCloud();
      state = state.copyWith(
        isBackingUp: false,
        lastBackupTime: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      state = state.copyWith(isBackingUp: false);
      rethrow;
    }
  }

  Future<void> triggerRestore() async { /* similar pattern */ }

  Future<void> saveApiKey(String key) async {
    await _secureStorage.write(
      key: AppConstants.weatherApiKeyEnvVar,
      value: key,
    );
  }
}
```

### 14. Admin System Management (Requirement 14)

**New Files:**
- `lib/features/admin/presentation/screens/admin_screen.dart`
- `lib/features/admin/presentation/providers/admin_providers.dart`
- `lib/features/admin/data/repositories/admin_repository.dart`

**Admin Repository:**

```dart
class AdminRepository {
  final DatabaseHelper _db;

  Future<List<UserProfileModel>> getAllUsers() async {
    final db = await _db.database;
    final rows = await db.query('user_profiles');
    return rows.map(UserProfileModel.fromMap).toList();
  }

  Future<void> setUserDisabled(String userId, bool disabled) async {
    final db = await _db.database;
    await db.update(
      'user_profiles',
      {'is_disabled': disabled ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>> getSystemConfig() async { /* ... */ }
  Future<void> updateSystemConfig(Map<String, dynamic> config) async { /* ... */ }
}
```

**Route Guard:**
Admin route includes a role check in the GoRouter redirect:

```dart
GoRoute(
  path: AppRoutes.admin,
  redirect: (context, state) {
    final userRole = /* read from profile */;
    if (userRole != 'admin') return AppRoutes.dashboard;
    return null;
  },
  builder: (context, state) => const AdminScreen(),
),
```

### 15. Image Display in Wardrobe (Requirement 15)

**Shared Widget:** `lib/shared/widgets/clothing_thumbnail.dart`

```dart
class ClothingThumbnail extends StatelessWidget {
  final String? photoPath;
  final double size;

  const ClothingThumbnail({super.key, this.photoPath, this.size = 48});

  @override
  Widget build(BuildContext context) {
    if (photoPath == null) {
      return _placeholder();
    }
    final file = File(photoPath!);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) {
                debugPrint('Image load error: $photoPath - $error');
                return _placeholder();
              },
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          debugPrint('Missing photo file: $photoPath');
          return _placeholder();
        }
        return SizedBox(width: size, height: size); // Loading
      },
    );
  }

  Widget _placeholder() => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.checkroom_outlined, color: AppColors.textMuted),
  );
}
```

## Data Models

All existing models are retained as-is. New additions:

### SystemConfig Model (Admin)

```dart
class SystemConfigModel {
  final int defaultMorningHour;
  final int defaultMorningMinute;
  final int defaultEveningHour;
  final int defaultEveningMinute;
  final int weatherCacheDurationMinutes;
  final DateTime updatedAt;
  const SystemConfigModel({...});
}
```

This is stored in SharedPreferences (key-value) rather than SQLite since it's system-wide configuration not tied to a user.

### Database Schema Extension

The existing `user_profiles` table needs an additional column for the admin feature:

```sql
ALTER TABLE user_profiles ADD COLUMN is_disabled INTEGER NOT NULL DEFAULT 0;
ALTER TABLE user_profiles ADD COLUMN role TEXT NOT NULL DEFAULT 'user';
```

This is handled in `_onUpgrade` when database version increments to 2.

## Interfaces

### Provider Dependency Graph

```
authStateProvider (Stream<User?>)
    └── currentUserIdProvider (String)
        └── activeProfileIdProvider (String) ← multi-profile switching
            ├── wardrobeListProvider
            ├── outfitLogListProvider
            ├── suggestionsProvider
            └── userProfileProvider

currentWeatherProvider (WeatherSnapshot)
    └── suggestionsProvider

settingsProvider (SettingsState)
    └── NotificationService
    └── BackupService
```

### Navigation Routes (Complete)

| Route | Screen | Auth Required | Admin Only |
|-------|--------|:---:|:---:|
| `/login` | LoginScreen | No | No |
| `/register` | RegisterScreen | No | No |
| `/onboarding` | OnboardingScreen | No | No |
| `/` | DashboardScreen | Yes | No |
| `/wardrobe` | WardrobeScreen | Yes | No |
| `/wardrobe/add` | AddClothingItemScreen | Yes | No |
| `/wardrobe/edit/:id` | AddClothingItemScreen (edit mode) | Yes | No |
| `/log-outfit` | LogOutfitScreen | Yes | No |
| `/log-outfit/rate/:id` | ComfortRatingScreen | Yes | No |
| `/suggestions` | SuggestionsScreen | Yes | No |
| `/history` | HistoryScreen | Yes | No |
| `/settings` | SettingsScreen | Yes | No |
| `/profile` | ProfileScreen | Yes | No |
| `/admin` | AdminScreen | Yes | Yes |

## Error Handling

All error handling follows the existing `AppException` hierarchy:

| Exception | When |
|-----------|------|
| `ValidationException` | Form validation failures (empty name, invalid score) |
| `UnauthorizedException` | Auth guard rejects access, login fails |
| `BackupException` | Backup/restore operations fail |
| `NetworkException` | Weather API or Firebase calls fail |

**Error Flow Pattern:**
1. Repository/Service throws typed exception
2. StateNotifier catches and sets `AsyncValue.error(e, st)`
3. Screen widget's `.when(error: ...)` renders user-facing error message
4. Retryable operations show a retry button that re-invokes the notifier method

**Form Error Pattern:**
- Validation errors are stored in the form state (e.g., `ClothingItemFormState.errorMessage`)
- Displayed inline below the relevant field
- Cleared on next input change

## Testing Strategy

### Unit Tests
- Repository methods: verify CRUD operations with in-memory SQLite
- Model serialization: verify `fromMap`/`toMap` round-trips
- SuggestionEngine: verify sorting and filtering logic
- Form validation: verify required field checks and score range validation

### Widget Tests
- Screen rendering with mocked providers
- Navigation behavior (tap → correct route)
- Empty states and error states display correctly
- Filter interactions update displayed data

### Integration Tests
- Full outfit logging flow: select items → save → rate comfort → dashboard
- Auth guard: unauthenticated access redirects, post-login restores route
- Backup/restore: trigger backup → verify data → restore on clean state

### Property-Based Tests
- See Correctness Properties section below for universal properties tested with 100+ generated inputs

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Active items filter invariant

*For any* set of clothing items in the wardrobe catalog with varying `is_active` states and user IDs, querying items for a specific user SHALL return only items where `user_id` matches AND `is_active` is true — never inactive items or items belonging to other users.

**Validates: Requirements 1.1, 1.5**

### Property 2: Wardrobe filter correctness

*For any* wardrobe filter configuration (category, fabric, or sensory tag) and any set of clothing items, the filtered result SHALL contain only items matching all specified filter criteria, and SHALL not exclude any item that matches all criteria.

**Validates: Requirements 1.6**

### Property 3: Clothing item persistence round-trip

*For any* valid `ClothingItemModel` (with non-empty name and category), saving it via the wardrobe repository and then retrieving it by ID SHALL yield a model with all fields equivalent to the original.

**Validates: Requirements 2.1, 2.5**

### Property 4: Clothing item form validation rejects invalid input

*For any* input string that is empty or composed entirely of whitespace characters provided as name or category, the clothing item form validation SHALL reject the submission and report an error.

**Validates: Requirements 2.4**

### Property 5: Outfit log preserves item selection and weather link

*For any* non-empty set of clothing item IDs and any existing weather snapshot, creating an outfit log SHALL produce a persisted record containing exactly the selected item IDs, the current date, and a reference to the most recent weather snapshot ID.

**Validates: Requirements 3.2, 3.3**

### Property 6: Comfort rating persistence round-trip

*For any* valid `ComfortRatingModel` with overall score in [1,5] and linked to an existing outfit log ID, saving via the repository and retrieving by `outfit_log_id` SHALL yield a model with all fields equivalent to the original.

**Validates: Requirements 4.1**

### Property 7: Comfort score validation range

*For any* integer value, the comfort rating validation SHALL accept only values in the range [1, 5] inclusive. All values outside this range SHALL be rejected before persistence.

**Validates: Requirements 4.4**

### Property 8: Suggestions sorted by descending comfort score

*For any* set of wardrobe items with associated historical comfort scores, the suggestion engine output SHALL be sorted in descending order by comfort score — that is, for every adjacent pair (a, b) in the result, `score(a) >= score(b)`.

**Validates: Requirements 5.2**

### Property 9: History entries sorted in reverse chronological order

*For any* set of outfit logs with varying `logged_date` values, querying logs for a user SHALL return them sorted by date descending — the most recent log appears first.

**Validates: Requirements 7.1**

### Property 10: History filter correctness

*For any* date range filter and/or category filter applied to a set of outfit logs, the filtered result SHALL contain only logs whose `logged_date` falls within the specified range AND whose items include the specified category.

**Validates: Requirements 7.4**

### Property 11: Auth guard redirect for protected routes

*For any* protected route (not in the exempt set of login, register, onboarding), accessing it without authentication SHALL result in a redirect to the login route.

**Validates: Requirements 8.1**

### Property 12: Post-login redirect preserves original destination

*For any* originally-requested protected route, after successful login the router SHALL redirect to that exact route rather than a default destination.

**Validates: Requirements 8.2**

### Property 13: Profile update persistence round-trip

*For any* valid `UserProfileModel` update (including sensory preferences from onboarding), saving the profile and re-reading it SHALL yield a model with all updated fields matching the saved values.

**Validates: Requirements 9.4, 12.2**

### Property 14: Multi-profile context isolation

*For any* dependent profile switch, all subsequent data queries (wardrobe items, outfit logs, comfort ratings) SHALL return only data where `user_id` matches the active dependent's ID — never data from the caregiver's own profile or other dependents.

**Validates: Requirements 10.2**

### Property 15: Timezone-aware notification scheduling

*For any* configured reminder time and timezone, the scheduled notification's local delivery time SHALL correspond to the configured hour and minute in the user's local timezone.

**Validates: Requirements 11.5**

### Property 16: Admin user list completeness

*For any* set of registered user accounts in the database, the admin panel query SHALL return all accounts with their correct enabled/disabled status indicator.

**Validates: Requirements 14.1, 14.2**

### Property 17: Admin role restriction

*For any* user without the admin role, attempting to access the admin route SHALL result in a redirect away from the admin panel.

**Validates: Requirements 14.5**

### Property 18: Photo display with missing file fallback

*For any* `ClothingItemModel` where `photoPath` references a non-existent file, the thumbnail widget SHALL render a placeholder icon rather than throwing an error or displaying a broken image.

**Validates: Requirements 15.1, 15.2**
