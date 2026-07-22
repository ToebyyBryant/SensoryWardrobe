import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/clothing_item_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/wardrobe_providers.dart';

/// P2.0 — Add / Edit a clothing item with sensory tags.
class AddClothingItemScreen extends ConsumerStatefulWidget {
  const AddClothingItemScreen({super.key});

  @override
  ConsumerState<AddClothingItemScreen> createState() =>
      _AddClothingItemScreenState();
}

class _AddClothingItemScreenState
    extends ConsumerState<AddClothingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fabricController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  int _warmthLevel = 3;
  final Set<String> _selectedTags = {};
  String? _photoPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fabricController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = ref.read(activeProfileProvider);
      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in required before adding items.')),
        );
        return;
      }

      setState(() => _isSaving = true);
      try {
        final now = DateTime.now();
        final item = ClothingItemModel(
          id: now.microsecondsSinceEpoch.toString(),
          userId: profile.id,
          name: _nameController.text.trim(),
          category: _selectedCategory!,
          fabric: _fabricController.text.trim().isEmpty
              ? null
              : _fabricController.text.trim(),
          sensoryTags: _selectedTags.toList(),
          warmthLevel: _warmthLevel,
          photoPath: _photoPath,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        await ref.read(wardrobeItemsProvider.notifier).addItem(item);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/wardrobe'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: AppConstants.clothingCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),

              // Fabric
              TextFormField(
                controller: _fabricController,
                decoration: const InputDecoration(
                  labelText: 'Fabric / Material',
                  hintText: 'e.g., 100% cotton',
                ),
              ),
              const SizedBox(height: 24),

              // Warmth level slider
              Text(
                'Warmth Level: $_warmthLevel',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: _warmthLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _warmthLevel.toString(),
                onChanged: (v) =>
                    setState(() => _warmthLevel = v.round()),
              ),
              const SizedBox(height: 24),

              // Sensory tags
              Text(
                'Sensory Tags',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: AppConstants.sensoryTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any sensory notes about this item...',
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveItem,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
