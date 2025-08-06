import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;
  final String userId;
  final String userPseudo;
  final String? userPhotoUrl;
  final String audioUrl;
  final Duration duration;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final String? description;

  StatusModel({
    required this.id,
    required this.userId,
    required this.userPseudo,
    this.userPhotoUrl,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.description,
  });

  factory StatusModel.fromMap(String id, Map<String, dynamic> map) {
    return StatusModel(
      id: id,
      userId: map['userId'] ?? '',
      userPseudo: map['userPseudo'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      audioUrl: map['audioUrl'] ?? '',
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userPseudo': userPseudo,
      'userPhotoUrl': userPhotoUrl,
      'audioUrl': audioUrl,
      'durationSeconds': duration.inSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'likedBy': likedBy,
      'description': description,
    };
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userPseudo,
    String? userPhotoUrl,
    String? audioUrl,
    Duration? duration,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    String? description,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userPseudo: userPseudo ?? this.userPseudo,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      description: description ?? this.description,
    );
  }
}
