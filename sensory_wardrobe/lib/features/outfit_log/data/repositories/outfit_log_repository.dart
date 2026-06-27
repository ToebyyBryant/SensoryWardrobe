import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/outfit_log_model.dart';
import '../models/comfort_rating_model.dart';

/// P4.0 — Log Outfit & Rate Comfort (DS3 + DS4)
class OutfitLogRepository {
  final DatabaseHelper _db;

  OutfitLogRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  // ── Outfit Logs ─────────────────────────────────────────────────────────────

  Future<void> saveOutfitLog(OutfitLogModel log) async {
    final db = await _db.database;
    await db.insert(
      'outfit_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OutfitLogModel>> getLogsForUser(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'outfit_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'logged_date DESC',
    );
    return rows.map(OutfitLogModel.fromMap).toList();
  }

  Future<OutfitLogModel?> getLogById(String id) async {
    final db = await _db.database;
    final rows =
        await db.query('outfit_logs', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return OutfitLogModel.fromMap(rows.first);
  }

  Future<OutfitLogModel?> getLogForDate(
      String userId, DateTime date) async {
    final db = await _db.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final rows = await db.query(
      'outfit_logs',
      where: "user_id = ? AND logged_date LIKE ?",
      whereArgs: [userId, '$dateStr%'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OutfitLogModel.fromMap(rows.first);
  }

  // ── Comfort Ratings ──────────────────────────────────────────────────────────

  Future<void> saveComfortRating(ComfortRatingModel rating) async {
    final db = await _db.database;
    await db.insert(
      'comfort_ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ComfortRatingModel?> getRatingForLog(String outfitLogId) async {
    final db = await _db.database;
    final rows = await db.query(
      'comfort_ratings',
      where: 'outfit_log_id = ?',
      whereArgs: [outfitLogId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ComfortRatingModel.fromMap(rows.first);
  }

  Future<List<ComfortRatingModel>> getRatingsForUser(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'comfort_ratings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'rated_at DESC',
    );
    return rows.map(ComfortRatingModel.fromMap).toList();
  }

  /// Returns average overall comfort score grouped by item_id.
  /// Used by P5.0 (suggestions engine).
  Future<Map<String, double>> getAverageScorePerItem(String userId) async {
    final db = await _db.database;
    // Join outfit_logs → comfort_ratings then aggregate
    final rows = await db.rawQuery('''
      SELECT ol.item_ids, AVG(cr.overall_score) AS avg_score
      FROM outfit_logs ol
      JOIN comfort_ratings cr ON cr.outfit_log_id = ol.id
      WHERE ol.user_id = ?
      GROUP BY ol.id
    ''', [userId]);

    final Map<String, List<double>> itemScores = {};
    for (final row in rows) {
      final avgScore = (row['avg_score'] as num).toDouble();
      // item_ids is a JSON array string
      final ids = (row['item_ids'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      for (final id in ids) {
        itemScores.putIfAbsent(id, () => []).add(avgScore);
      }
    }

    return itemScores.map(
      (id, scores) =>
          MapEntry(id, scores.reduce((a, b) => a + b) / scores.length),
    );
  }
}
