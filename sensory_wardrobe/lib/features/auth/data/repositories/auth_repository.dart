import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/app_exception.dart';

/// P1.0 — Manage User Accounts & Profiles
/// Handles Firebase Auth + local profile storage.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final DatabaseHelper _db;

  AuthRepository({FirebaseAuth? firebaseAuth, DatabaseHelper? db})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _db = db ?? DatabaseHelper();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Register a new user with email/password.
  Future<UserProfileModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);

      final profile = UserProfileModel(
        id: credential.user!.uid,
        displayName: displayName,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveProfileLocally(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw ValidationException(e.message ?? 'Registration failed');
    }
  }

  /// Sign in an existing user.
  Future<UserProfileModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final profile = await getProfileById(uid);
      if (profile == null) {
        // First login on a new device — create local profile from Firebase user
        final newProfile = UserProfileModel(
          id: uid,
          displayName: credential.user!.displayName ?? 'User',
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveProfileLocally(newProfile);
        return newProfile;
      }
      return profile;
    } on FirebaseAuthException catch (e) {
      throw UnauthorizedException(e.message ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserProfileModel?> getProfileById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return UserProfileModel.fromMap(rows.first);
  }

  Future<List<UserProfileModel>> getDependentProfiles(
      String caregiverId) async {
    final db = await _db.database;
    final rows = await db.query(
      'user_profiles',
      where: 'caregiver_id = ?',
      whereArgs: [caregiverId],
    );
    return rows.map(UserProfileModel.fromMap).toList();
  }

  Future<void> _saveProfileLocally(UserProfileModel profile) async {
    final db = await _db.database;
    await db.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    final db = await _db.database;
    await db.update(
      'user_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }
}
