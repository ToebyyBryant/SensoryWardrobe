import 'dart:convert';
import 'package:flutter/foundation.dart';

/// DS3: Outfit Log — daily outfit selection linked to a weather snapshot.
@immutable
class OutfitLogModel {
  final String id;
  final String userId;
  final DateTime loggedDate;
  final List<String> itemIds;
  final String? weatherSnapshotId;
  final String? notes;
  final DateTime createdAt;

  const OutfitLogModel({
    required this.id,
    required this.userId,
    required this.loggedDate,
    required this.itemIds,
    this.weatherSnapshotId,
    this.notes,
    required this.createdAt,
  });

  factory OutfitLogModel.fromMap(Map<String, dynamic> map) {
    return OutfitLogModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      loggedDate: DateTime.parse(map['logged_date'] as String),
      itemIds: List<String>.from(jsonDecode(map['item_ids'] as String)),
      weatherSnapshotId: map['weather_snapshot_id'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'logged_date': loggedDate.toIso8601String(),
        'item_ids': jsonEncode(itemIds),
        'weather_snapshot_id': weatherSnapshotId,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
