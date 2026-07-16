import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../backup/presentation/providers/backup_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../providers/settings_providers.dart';

/// P7.0 Notifications + P8.0 Backup settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickAndScheduleReminder(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required TimeOfDay initial,
    required Future<void> Function(String value) persist,
    required Future<void> Function(int hour, int minute) schedule,
  }) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: title,
    );

    if (selected == null) return;

    final hh = selected.hour.toString().padLeft(2, '0');
    final mm = selected.minute.toString().padLeft(2, '0');
    final value = '$hh:$mm';

    await persist(value);
    await schedule(selected.hour, selected.minute);
  }

  TimeOfDay _parseOrDefault(String? value, TimeOfDay fallback) {
    if (value == null || !value.contains(':')) return fallback;
    final parts = value.split(':');
    if (parts.length != 2) return fallback;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return fallback;

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final notificationService = ref.read(notificationServiceProvider);
    final backupState = ref.watch(backupNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Enable reminders'),
            subtitle: const Text('Morning log and evening comfort prompts'),
            value: settings.notificationsEnabled,
            onChanged: (enabled) async {
              await settingsNotifier.setNotificationsEnabled(enabled);

              if (!enabled) {
                await notificationService.cancelAll();
                return;
              }

              await notificationService.initialize();
              final morning = _parseOrDefault(
                settings.morningReminderTime,
                const TimeOfDay(hour: 8, minute: 0),
              );
              final evening = _parseOrDefault(
                settings.eveningReminderTime,
                const TimeOfDay(hour: 19, minute: 0),
              );

              await notificationService.scheduleMorningReminder(
                morning.hour,
                morning.minute,
              );
              await notificationService.scheduleEveningRatingReminder(
                evening.hour,
                evening.minute,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Morning Outfit Reminder'),
            subtitle: Text(settings.morningReminderTime ?? 'Tap to set time'),
            trailing: const Icon(Icons.chevron_right),
            onTap: settings.notificationsEnabled
                ? () => _pickAndScheduleReminder(
                      context,
                      ref,
                      title: 'Morning reminder',
                      initial: _parseOrDefault(
                        settings.morningReminderTime,
                        const TimeOfDay(hour: 8, minute: 0),
                      ),
                      persist: settingsNotifier.setMorningReminderTime,
                      schedule: notificationService.scheduleMorningReminder,
                    )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Evening Comfort Rating Reminder'),
            subtitle: Text(settings.eveningReminderTime ?? 'Tap to set time'),
            trailing: const Icon(Icons.chevron_right),
            onTap: settings.notificationsEnabled
                ? () => _pickAndScheduleReminder(
                      context,
                      ref,
                      title: 'Evening reminder',
                      initial: _parseOrDefault(
                        settings.eveningReminderTime,
                        const TimeOfDay(hour: 19, minute: 0),
                      ),
                      persist: settingsNotifier.setEveningReminderTime,
                      schedule:
                          notificationService.scheduleEveningRatingReminder,
                    )
                : null,
          ),
          const Divider(),
          const _SectionHeader('Weather'),
          ListTile(
            leading: const Icon(Icons.thermostat_outlined),
            title: const Text('Temperature Unit'),
            subtitle: Text(settings.weatherUnit == 'imperial'
                ? 'Fahrenheit'
                : 'Celsius'),
            trailing: DropdownButton<String>(
              value: settings.weatherUnit,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'metric', child: Text('Celsius')),
                DropdownMenuItem(
                    value: 'imperial', child: Text('Fahrenheit')),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setWeatherUnit(value);
                }
              },
            ),
          ),
          const ListTile(
            leading: Icon(Icons.vpn_key_outlined),
            title: Text('Weather API Key'),
            subtitle: Text('Required for weather data'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const _SectionHeader('Data & Backup'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Back Up Data'),
            subtitle: const Text('Encrypted sync to cloud'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ref.read(backupNotifierProvider.notifier).backup(),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Restore from Backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ref.read(backupNotifierProvider.notifier).restore(),
          ),
          if (backupState.message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(backupState.message!),
            ),
          const Divider(),
          const _SectionHeader('Accessibility'),
          const ListTile(
            leading: Icon(Icons.text_increase_outlined),
            title: Text('Large Text'),
            trailing: Switch(value: false, onChanged: null),
          ),
          const ListTile(
            leading: Icon(Icons.contrast_outlined),
            title: Text('High Contrast Mode'),
            trailing: Switch(value: false, onChanged: null),
          ),
          const Divider(),
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(activeProfileProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
      ),
    );
  }
}
