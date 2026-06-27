import 'dart:convert';
import 'package:flutter/foundation.dart';

/// DS2: Wardrobe Catalog item.
@immutable
class ClothingItemModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? color;
  final String? fabric;
  final List<String> sensoryTags;
  final int? warmthLevel; // 1–5
  final String? photoPath;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothingItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.color,
    this.fabric,
    this.sensoryTags = const [],
    this.warmthLevel,
    this.photoPath,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClothingItemModel.fromMap(Map<String, dynamic> map) {
    return ClothingItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      color: map['color'] as String?,
      fabric: map['fabric'] as String?,
      sensoryTags: map['sensory_tags'] != null
          ? List<String>.from(jsonDecode(map['sensory_tags'] as String))
          : [],
      warmthLevel: map['warmth_level'] as int?,
      photoPath: map['photo_path'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'category': category,
        'color': color,
        'fabric': fabric,
        'sensory_tags': jsonEncode(sensoryTags),
        'warmth_level': warmthLevel,
        'photo_path': photoPath,
        'notes': notes,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ClothingItemModel copyWith({
    String? name,
    String? category,
    String? color,
    String? fabric,
    List<String>? sensoryTags,
    int? warmthLevel,
    String? photoPath,
    String? notes,
    bool? isActive,
  }) {
    return ClothingItemModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      fabric: fabric ?? this.fabric,
      sensoryTags: sensoryTags ?? this.sensoryTags,
      warmthLevel: warmthLevel ?? this.warmthLevel,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
