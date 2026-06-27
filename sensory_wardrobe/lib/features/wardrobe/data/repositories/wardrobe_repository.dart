import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/clothing_item_model.dart';

/// P2.0 — Manage Wardrobe Catalog (DS2)
class WardrobeRepository {
  final DatabaseHelper _db;

  WardrobeRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<List<ClothingItemModel>> getItemsForUser(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'wardrobe_items',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'category ASC, name ASC',
    );
    return rows.map(ClothingItemModel.fromMap).toList();
  }

  Future<List<ClothingItemModel>> getItemsByCategory(
      String userId, String category) async {
    final db = await _db.database;
    final rows = await db.query(
      'wardrobe_items',
      where: 'user_id = ? AND category = ? AND is_active = 1',
      whereArgs: [userId, category],
    );
    return rows.map(ClothingItemModel.fromMap).toList();
  }

  Future<ClothingItemModel?> getItemById(String id) async {
    final db = await _db.database;
    final rows =
        await db.query('wardrobe_items', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ClothingItemModel.fromMap(rows.first);
  }

  Future<void> addItem(ClothingItemModel item) async {
    final db = await _db.database;
    await db.insert(
      'wardrobe_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(ClothingItemModel item) async {
    final db = await _db.database;
    await db.update(
      'wardrobe_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Soft-delete: mark item as inactive rather than destroying data.
  Future<void> archiveItem(String id) async {
    final db = await _db.database;
    await db.update(
      'wardrobe_items',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
