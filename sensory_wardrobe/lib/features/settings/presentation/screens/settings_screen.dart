import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// P7.0 Notifications + P8.0 Backup settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          _SectionHeader('Notifications'),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Morning Outfit Reminder'),
            subtitle: Text('Tap to set time'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.star_outline),
            title: Text('Evening Comfort Rating Reminder'),
            subtitle: Text('Tap to set time'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          _SectionHeader('Weather'),
          ListTile(
            leading: Icon(Icons.thermostat_outlined),
            title: Text('Temperature Unit'),
            subtitle: Text('Celsius / Fahrenheit'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.vpn_key_outlined),
            title: Text('Weather API Key'),
            subtitle: Text('Required for weather data'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          _SectionHeader('Data & Backup'),
          ListTile(
            leading: Icon(Icons.cloud_upload_outlined),
            title: Text('Back Up Data'),
            subtitle: Text('Encrypted sync to cloud'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.cloud_download_outlined),
            title: Text('Restore from Backup'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          _SectionHeader('Accessibility'),
          ListTile(
            leading: Icon(Icons.text_increase_outlined),
            title: Text('Large Text'),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.contrast_outlined),
            title: Text('High Contrast Mode'),
            trailing: Switch(value: false, onChanged: null),
          ),
          Divider(),
          _SectionHeader('Account'),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sign Out', style: TextStyle(color: Colors.red)),
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
