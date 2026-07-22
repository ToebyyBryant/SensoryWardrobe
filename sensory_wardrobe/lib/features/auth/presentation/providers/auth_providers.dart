import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/user_profile_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/database/seed_data.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ── Firebase auth state stream ────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ── Active user profile ───────────────────────────────────────────────────────

final activeProfileProvider =
    StateNotifierProvider<ActiveProfileNotifier, UserProfileModel?>(
  (ref) => ActiveProfileNotifier(ref.watch(authRepositoryProvider)),
);

class ActiveProfileNotifier extends StateNotifier<UserProfileModel?> {
  final AuthRepository _repo;

  ActiveProfileNotifier(this._repo) : super(null);

  Future<void> loadProfile(String uid) async {
    state = await _repo.getProfileById(uid);
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = await _repo.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    // Seed example data for new users
    if (state != null) {
      await SeedData.seedIfNeeded(state!.id);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = await _repo.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = null;
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    await _repo.updateProfile(profile);
    state = profile;
  }
}

// ── Dependent profiles (caregiver view) ─────────────────────────────────────

final dependentProfilesProvider =
    FutureProvider.family<List<UserProfileModel>, String>(
  (ref, caregiverId) async {
    return ref.watch(authRepositoryProvider).getDependentProfiles(caregiverId);
  },
);
