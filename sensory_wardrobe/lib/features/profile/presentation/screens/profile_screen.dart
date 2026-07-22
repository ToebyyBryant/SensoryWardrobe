import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// Profile display + edit screen.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final editState = ref.watch(profileEditProvider);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_editing) {
      _nameController.text = profile.displayName;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.teal,
              child: Text(
                profile.displayName.isNotEmpty
                    ? profile.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Display name
          if (_editing)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            )
          else
            Center(
              child: Text(
                profile.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          const SizedBox(height: 8),

          // Email (read-only)
          Center(
            child: Text(
              profile.email ?? 'No email',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Sensory preferences section
          _SensoryPreferencesCard(
            profile: profile,
            onSave: (prefs) async {
              final updated = profile.copyWith(sensoryPreferences: prefs);
              await ref.read(profileEditProvider.notifier).save(updated);
            },
          ),
          const SizedBox(height: 12),

          // Account info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Info',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Account Type',
                    value: profile.isDependent ? 'Dependent' : 'Independent',
                  ),
                  _InfoRow(
                    label: 'Member Since',
                    value: _formatDate(profile.createdAt),
                  ),
                  if (profile.caregiverId != null)
                    const _InfoRow(
                      label: 'Managed By',
                      value: 'Caregiver',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save / Cancel buttons when editing
          if (_editing) ...[
            if (editState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  editState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _editing = false);
                      _nameController.text = profile.displayName;
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: editState.isSaving
                        ? null
                        : () async {
                            final updated = profile.copyWith(
                              displayName: _nameController.text.trim(),
                            );
                            await ref
                                .read(profileEditProvider.notifier)
                                .save(updated);
                            if (mounted) {
                              setState(() => _editing = false);
                            }
                          },
                    child: editState.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SensoryPreferencesCard extends StatefulWidget {
  final dynamic profile;
  final Future<void> Function(Map<String, dynamic> prefs) onSave;

  const _SensoryPreferencesCard({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_SensoryPreferencesCard> createState() =>
      _SensoryPreferencesCardState();
}

class _SensoryPreferencesCardState extends State<_SensoryPreferencesCard> {
  late Set<String> _selectedTags;
  late int _warmthPreference;
  bool _editMode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefs = widget.profile.sensoryPreferences as Map<String, dynamic>?;
    _selectedTags = Set<String>.from(
      (prefs?['preferred_tags'] as List<dynamic>?) ?? [],
    );
    _warmthPreference = (prefs?['warmth_preference'] as int?) ?? 3;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave({
      'preferred_tags': _selectedTags.toList(),
      'warmth_preference': _warmthPreference,
    });
    if (mounted) {
      setState(() {
        _saving = false;
        _editMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sensory Preferences',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!_editMode)
                  TextButton(
                    onPressed: () => setState(() => _editMode = true),
                    child: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (!_editMode) ...[
              if (_selectedTags.isEmpty)
                const Text(
                  'No preferences set. Tap Edit to configure.',
                  style: TextStyle(color: AppColors.textMuted),
                )
              else ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedTags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                AppColors.teal.withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Warmth preference: $_warmthPreference/5',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ],

            if (_editMode) ...[
              const Text(
                'Select textures you find comfortable:',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: AppConstants.sensoryTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    selectedColor: AppColors.teal.withValues(alpha: 0.2),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Warmth preference: $_warmthPreference '
                '(1=light, 5=warm)',
              ),
              Slider(
                value: _warmthPreference.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_warmthPreference',
                onChanged: (v) =>
                    setState(() => _warmthPreference = v.toInt()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editMode = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Preferences'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
