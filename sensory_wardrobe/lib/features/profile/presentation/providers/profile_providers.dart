import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/models/user_profile_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Repository re-export for profile screens ──────────────────────────────────

final profileRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryProvider);
});

// ── Profile edit form state ───────────────────────────────────────────────────

class ProfileEditState {
  final bool isSaving;
  final String? error;
  final bool saved;

  const ProfileEditState({
    this.isSaving = false,
    this.error,
    this.saved = false,
  });

  ProfileEditState copyWith({bool? isSaving, String? error, bool? saved}) =>
      ProfileEditState(
        isSaving: isSaving ?? this.isSaving,
        error: error,
        saved: saved ?? this.saved,
      );
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>(
  (ref) => ProfileEditNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(activeProfileProvider.notifier),
  ),
);

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final AuthRepository _repo;
  final ActiveProfileNotifier _activeProfileNotifier;

  ProfileEditNotifier(this._repo, this._activeProfileNotifier)
      : super(const ProfileEditState());

  Future<void> save(UserProfileModel updated) async {
    state = state.copyWith(isSaving: true, error: null, saved: false);
    try {
      await _repo.updateProfile(updated);
      await _activeProfileNotifier.updateProfile(updated);
      state = state.copyWith(isSaving: false, saved: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void reset() => state = const ProfileEditState();
}

// ── Dependent profiles list ───────────────────────────────────────────────────

final dependentProfileListProvider =
    FutureProvider<List<UserProfileModel>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return [];
  return ref.watch(authRepositoryProvider).getDependentProfiles(profile.id);
});
