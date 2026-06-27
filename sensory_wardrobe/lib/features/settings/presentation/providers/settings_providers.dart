import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

// ── SharedPreferences instance ────────────────────────────────────────────────

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// ── Settings notifier ─────────────────────────────────────────────────────────

class AppSettings {
  final bool notificationsEnabled;
  final String weatherUnit; // 'metric' | 'imperial'
  final String? morningReminderTime; // "HH:mm"
  final String? eveningReminderTime; // "HH:mm"
  final bool largeText;
  final bool highContrast;

  const AppSettings({
    this.notificationsEnabled = true,
    this.weatherUnit = 'metric',
    this.morningReminderTime,
    this.eveningReminderTime,
    this.largeText = false,
    this.highContrast = false,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    String? weatherUnit,
    String? morningReminderTime,
    String? eveningReminderTime,
    bool? largeText,
    bool? highContrast,
  }) {
    return AppSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      weatherUnit: weatherUnit ?? this.weatherUnit,
      morningReminderTime:
          morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime:
          eveningReminderTime ?? this.eveningReminderTime,
      largeText: largeText ?? this.largeText,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool(
              AppConstants.prefNotificationsEnabled) ??
          true,
      weatherUnit:
          prefs.getString(AppConstants.prefWeatherUnit) ?? 'metric',
      morningReminderTime:
          prefs.getString(AppConstants.prefMorningReminderTime),
      eveningReminderTime:
          prefs.getString(AppConstants.prefEveningReminderTime),
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefNotificationsEnabled, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setWeatherUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefWeatherUnit, unit);
    state = state.copyWith(weatherUnit: unit);
  }

  Future<void> setMorningReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefMorningReminderTime, time);
    state = state.copyWith(morningReminderTime: time);
  }

  Future<void> setEveningReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefEveningReminderTime, time);
    state = state.copyWith(eveningReminderTime: time);
  }
}
