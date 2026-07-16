import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../wardrobe/presentation/providers/wardrobe_providers.dart';
import '../../data/models/outfit_log_model.dart';
import '../providers/outfit_log_providers.dart';
/// P4.0 — Log today's outfit selection.
class LogOutfitScreen extends ConsumerStatefulWidget {
  const LogOutfitScreen({super.key});

  @override
  ConsumerState<LogOutfitScreen> createState() => _LogOutfitScreenState();
}

class _LogOutfitScreenState extends ConsumerState<LogOutfitScreen> {
  final Set<String> _selectedItemIds = {};
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveLog() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one wardrobe item.')),
      );
      return;
    }

    final profile = ref.read(activeProfileProvider);
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final log = OutfitLogModel(
        id: now.microsecondsSinceEpoch.toString(),
        userId: profile.id,
        loggedDate: now,
        itemIds: _selectedItemIds.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: now,
      );

      await ref.read(outfitLogsProvider.notifier).saveLog(log);
      if (mounted) {
        context.go('${AppRoutes.logOutfit}/rate?logId=${log.id}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save outfit log: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeAsync = ref.watch(wardrobeItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Outfit")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: wardrobeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load wardrobe: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No wardrobe items found. Add items first.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CheckboxListTile(
                      title: Text(item.name),
                      subtitle: Text(item.category),
                      value: _selectedItemIds.contains(item.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedItemIds.add(item.id);
                          } else {
                            _selectedItemIds.remove(item.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLog,
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Outfit and Rate Comfort'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
