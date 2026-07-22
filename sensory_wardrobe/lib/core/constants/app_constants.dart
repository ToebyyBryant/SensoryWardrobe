/// App-wide constants.
class AppConstants {
  // Open-Meteo (free, no API key required)
  static const weatherApiBaseUrl = 'https://api.open-meteo.com/v1';
  static const weatherApiKeyEnvVar = 'WEATHER_API_KEY'; // legacy, no longer needed

  // Database
  static const dbName = 'sensory_wardrobe.db';
  static const dbVersion = 1;

  // Comfort rating scale
  static const minComfortScore = 1;
  static const maxComfortScore = 5;

  // Sensory tag categories
  static const sensoryTags = [
    'soft',
    'smooth',
    'stretchy',
    'loose-fit',
    'tight-fit',
    'seamless',
    'tagless',
    'heavyweight',
    'lightweight',
    'breathable',
    'moisture-wicking',
    'scratchy',
    'rough',
    'itchy',
  ];

  // Clothing categories
  static const clothingCategories = [
    'Top',
    'Bottom',
    'Underwear',
    'Socks',
    'Shoes',
    'Jacket / Outerwear',
    'Dress / Romper',
    'Sleepwear',
    'Accessories',
  ];

  // Warmth levels (1 = very light, 5 = very warm)
  static const minWarmthLevel = 1;
  static const maxWarmthLevel = 5;

  // Notification IDs
  static const morningReminderNotifId = 1001;
  static const eveningRatingReminderNotifId = 1002;

  // Shared preferences keys
  static const prefActiveProfileId = 'active_profile_id';
  static const prefOnboardingComplete = 'onboarding_complete';
  static const prefWeatherUnit = 'weather_unit'; // 'metric' | 'imperial'
  static const prefNotificationsEnabled = 'notifications_enabled';
  static const prefMorningReminderTime = 'morning_reminder_time';
  static const prefEveningReminderTime = 'evening_reminder_time';
}
