import 'package:flutter/foundation.dart';

/// DS4: Comfort Rating — post-wear score linked to an outfit log.
@immutable
class ComfortRatingModel {
  final String id;
  final String outfitLogId;
  final String userId;
  final int overallScore; // 1–5
  final int? textureScore; // 1–5
  final int? pressureScore; // 1–5
  final int? temperatureScore; // 1–5
  final String? notes;
  final DateTime ratedAt;

  const ComfortRatingModel({
    required this.id,
    required this.outfitLogId,
    required this.userId,
    required this.overallScore,
    this.textureScore,
    this.pressureScore,
    this.temperatureScore,
    this.notes,
    required this.ratedAt,
  });

  factory ComfortRatingModel.fromMap(Map<String, dynamic> map) {
    return ComfortRatingModel(
      id: map['id'] as String,
      outfitLogId: map['outfit_log_id'] as String,
      userId: map['user_id'] as String,
      overallScore: map['overall_score'] as int,
      textureScore: map['texture_score'] as int?,
      pressureScore: map['pressure_score'] as int?,
      temperatureScore: map['temperature_score'] as int?,
      notes: map['notes'] as String?,
      ratedAt: DateTime.parse(map['rated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'outfit_log_id': outfitLogId,
        'user_id': userId,
        'overall_score': overallScore,
        'texture_score': textureScore,
        'pressure_score': pressureScore,
        'temperature_score': temperatureScore,
        'notes': notes,
        'rated_at': ratedAt.toIso8601String(),
      };
}
