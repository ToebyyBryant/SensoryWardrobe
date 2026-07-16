import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/error/app_exception.dart';

/// P8.0 — Backup & Restore Data
/// Serializes all DS1–DS4 tables and syncs to Firestore.
class BackupService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DatabaseHelper _db;

  BackupService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DatabaseHelper? db,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? DatabaseHelper();

  String? get _uid => _auth.currentUser?.uid;

  /// Exports all local tables and saves to Firestore under the user's doc.
  Future<void> backupToCloud() async {
    final uid = _uid;
    if (uid == null) throw const BackupException('Not signed in');

    final db = await _db.database;
    final payload = <String, dynamic>{};

    for (final table in [
      'user_profiles',
      'wardrobe_items',
      'outfit_logs',
      'comfort_ratings',
      'weather_snapshots',
    ]) {
      final rows = await db.query(table);
      payload[table] = rows;
    }

    payload['backed_up_at'] = DateTime.now().toIso8601String();

    await _firestore
        .collection('backups')
        .doc(uid)
        .set({'data': jsonEncode(payload)}, SetOptions(merge: false));
  }

  /// Restores data from Firestore into local SQLite.
  Future<void> restoreFromCloud() async {
    final uid = _uid;
    if (uid == null) throw const BackupException('Not signed in');

    final doc =
        await _firestore.collection('backups').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      throw const BackupException('No backup found for this account');
    }

    final payload = jsonDecode(doc.data()!['data'] as String)
        as Map<String, dynamic>;

    final db = await _db.database;

    await db.transaction((txn) async {
      for (final table in [
        'weather_snapshots',
        'comfort_ratings',
        'outfit_logs',
        'wardrobe_items',
        'user_profiles',
      ]) {
        if (payload[table] != null) {
          final rows = (payload[table] as List)
              .cast<Map<String, dynamic>>();
          for (final row in rows) {
            await txn.insert(
              table,
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    });
  }
}
