import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userPseudo;
  final String? userPhotoUrl;
  final String videoUrl;
  final String caption;
  final String? challenge;
  final Duration duration;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int likes;
  final int views;
  final List<String> likedBy;
  final List<String> viewedBy;
  final List<String> filters;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userPseudo,
    this.userPhotoUrl,
    required this.videoUrl,
    required this.caption,
    this.challenge,
    required this.duration,
    required this.createdAt,
    required this.expiresAt,
    this.likes = 0,
    this.views = 0,
    this.likedBy = const [],
    this.viewedBy = const [],
    this.filters = const [],
  });

  factory StoryModel.fromMap(String id, Map<String, dynamic> map) {
    return StoryModel(
      id: id,
      userId: map['userId'] ?? '',
      userPseudo: map['userPseudo'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      videoUrl: map['videoUrl'] ?? '',
      caption: map['caption'] ?? '',
      challenge: map['challenge'],
      duration: Duration(seconds: map['durationSeconds'] ?? 15),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
      filters: List<String>.from(map['filters'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userPseudo': userPseudo,
      'userPhotoUrl': userPhotoUrl,
      'videoUrl': videoUrl,
      'caption': caption,
      'challenge': challenge,
      'durationSeconds': duration.inSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'likes': likes,
      'views': views,
      'likedBy': likedBy,
      'viewedBy': viewedBy,
      'filters': filters,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  StoryModel copyWith({
    String? id,
    String? userId,
    String? userPseudo,
    String? userPhotoUrl,
    String? videoUrl,
    String? caption,
    String? challenge,
    Duration? duration,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? likes,
    int? views,
    List<String>? likedBy,
    List<String>? viewedBy,
    List<String>? filters,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userPseudo: userPseudo ?? this.userPseudo,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      challenge: challenge ?? this.challenge,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      likedBy: likedBy ?? this.likedBy,
      viewedBy: viewedBy ?? this.viewedBy,
      filters: filters ?? this.filters,
    );
  }
}
