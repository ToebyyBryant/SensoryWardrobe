import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/clothing_item_model.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});

// ── Full wardrobe list for active user ────────────────────────────────────────

final wardrobeItemsProvider =
    StateNotifierProvider<WardrobeNotifier, AsyncValue<List<ClothingItemModel>>>(
  (ref) {
    final repo = ref.watch(wardrobeRepositoryProvider);
    final profile = ref.watch(activeProfileProvider);
    return WardrobeNotifier(repo, profile?.id);
  },
);

class WardrobeNotifier
    extends StateNotifier<AsyncValue<List<ClothingItemModel>>> {
  final WardrobeRepository _repo;
  final String? _userId;

  WardrobeNotifier(this._repo, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) load();
  }

  Future<void> load() async {
    if (_userId == null) return;
    try {
      final items = await _repo.getItemsForUser(_userId!);
      if (mounted) state = AsyncValue.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(ClothingItemModel item) async {
    await _repo.addItem(item);
    await load();
  }

  Future<void> updateItem(ClothingItemModel item) async {
    await _repo.updateItem(item);
    await load();
  }

  Future<void> archiveItem(String id) async {
    await _repo.archiveItem(id);
    await load();
  }
}

// ── Items filtered by category ────────────────────────────────────────────────

final wardrobeItemsByCategoryProvider =
    FutureProvider.family<List<ClothingItemModel>, String>(
  (ref, category) async {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return [];
    return ref
        .watch(wardrobeRepositoryProvider)
        .getItemsByCategory(profile.id, category);
  },
);

// ── Single item by ID ─────────────────────────────────────────────────────────

final clothingItemByIdProvider =
    FutureProvider.family<ClothingItemModel?, String>(
  (ref, id) =>
      ref.watch(wardrobeRepositoryProvider).getItemById(id),
);
