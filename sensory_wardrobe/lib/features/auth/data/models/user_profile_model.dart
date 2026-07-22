import 'dart:convert';

import 'package:flutter/foundation.dart';

/// DS1: User Profiles data model.
@immutable
class UserProfileModel {
  final String id;
  final String displayName;
  final String? email;
  final bool isDependent;
  final String? caregiverId;
  final Map<String, dynamic>? accessibilitySettings;
  final Map<String, dynamic>? sensoryPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileModel({
    required this.id,
    required this.displayName,
    this.email,
    this.isDependent = false,
    this.caregiverId,
    this.accessibilitySettings,
    this.sensoryPreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? sensoryPrefs;
    if (map['sensory_preferences'] != null) {
      final raw = map['sensory_preferences'] as String;
      if (raw.isNotEmpty) {
        sensoryPrefs =
            Map<String, dynamic>.from(_decodeJson(raw) as Map);
      }
    }

    return UserProfileModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String,
      email: map['email'] as String?,
      isDependent: (map['is_dependent'] as int) == 1,
      caregiverId: map['caregiver_id'] as String?,
      sensoryPreferences: sensoryPrefs,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
        'email': email,
        'is_dependent': isDependent ? 1 : 0,
        'caregiver_id': caregiverId,
        'sensory_preferences':
            sensoryPreferences != null ? _encodeJson(sensoryPreferences) : null,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static dynamic _decodeJson(String raw) {
    return jsonDecode(raw);
  }

  static String? _encodeJson(dynamic value) {
    if (value == null) return null;
    return jsonEncode(value);
  }

  UserProfileModel copyWith({
    String? displayName,
    String? email,
    bool? isDependent,
    String? caregiverId,
    Map<String, dynamic>? accessibilitySettings,
    Map<String, dynamic>? sensoryPreferences,
  }) {
    return UserProfileModel(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isDependent: isDependent ?? this.isDependent,
      caregiverId: caregiverId ?? this.caregiverId,
      accessibilitySettings:
          accessibilitySettings ?? this.accessibilitySettings,
      sensoryPreferences: sensoryPreferences ?? this.sensoryPreferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
