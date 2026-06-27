import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _fabricController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: dispatch to wardrobe notifier
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Clothing Item')),
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
                  onPressed: _saveItem,
                  child: const Text('Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
