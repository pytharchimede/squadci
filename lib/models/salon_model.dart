import 'package:cloud_firestore/cloud_firestore.dart';

class SalonModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int participantsCount;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;
  final List<String> participants;

  SalonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.participantsCount = 0,
    required this.createdAt,
    required this.lastActivity,
    this.isActive = true,
    this.participants = const [],
  });

  factory SalonModel.fromMap(String id, Map<String, dynamic> map) {
    return SalonModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏠',
      participantsCount: map['participantsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActivity: (map['lastActivity'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'participantsCount': participantsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivity': Timestamp.fromDate(lastActivity),
      'isActive': isActive,
      'participants': participants,
    };
  }

  SalonModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? participantsCount,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool? isActive,
    List<String>? participants,
  }) {
    return SalonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      participantsCount: participantsCount ?? this.participantsCount,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
      participants: participants ?? this.participants,
    );
  }
}

class MessageModel {
  final String id;
  final String salonId;
  final String userId;
  final String pseudoTemp;
  final String message;
  final MessageType type;
  final DateTime createdAt;
  final String? audioUrl;
  final Duration? audioDuration;

  MessageModel({
    required this.id,
    required this.salonId,
    required this.userId,
    required this.pseudoTemp,
    required this.message,
    required this.type,
    required this.createdAt,
    this.audioUrl,
    this.audioDuration,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      salonId: map['salonId'] ?? '',
      userId: map['userId'] ?? '',
      pseudoTemp: map['pseudoTemp'] ?? '',
      message: map['message'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map['type']}',
        orElse: () => MessageType.text,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      audioUrl: map['audioUrl'],
      audioDuration: map['audioDurationSeconds'] != null
          ? Duration(seconds: map['audioDurationSeconds'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'userId': userId,
      'pseudoTemp': pseudoTemp,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'audioUrl': audioUrl,
      'audioDurationSeconds': audioDuration?.inSeconds,
    };
  }
}

enum MessageType {
  text,
  audio,
  image,
  system,
}
