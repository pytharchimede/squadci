import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String pseudo;
  final String? email;
  final String? photoUrl;
  final String quartierPrefere;
  final DateTime inscritAt;
  final bool isAnonymous;
  final int points;
  final List<String> salonsRejoints;

  UserModel({
    required this.uid,
    required this.pseudo,
    this.email,
    this.photoUrl,
    required this.quartierPrefere,
    required this.inscritAt,
    this.isAnonymous = false,
    this.points = 0,
    this.salonsRejoints = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      pseudo: map['pseudo'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      quartierPrefere: map['quartierPrefere'] ?? '',
      inscritAt: (map['inscritAt'] as Timestamp).toDate(),
      isAnonymous: map['isAnonymous'] ?? false,
      points: map['points'] ?? 0,
      salonsRejoints: List<String>.from(map['salonsRejoints'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pseudo': pseudo,
      'email': email,
      'photoUrl': photoUrl,
      'quartierPrefere': quartierPrefere,
      'inscritAt': Timestamp.fromDate(inscritAt),
      'isAnonymous': isAnonymous,
      'points': points,
      'salonsRejoints': salonsRejoints,
    };
  }

  UserModel copyWith({
    String? uid,
    String? pseudo,
    String? email,
    String? photoUrl,
    String? quartierPrefere,
    DateTime? inscritAt,
    bool? isAnonymous,
    int? points,
    List<String>? salonsRejoints,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      pseudo: pseudo ?? this.pseudo,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      quartierPrefere: quartierPrefere ?? this.quartierPrefere,
      inscritAt: inscritAt ?? this.inscritAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      points: points ?? this.points,
      salonsRejoints: salonsRejoints ?? this.salonsRejoints,
    );
  }
}
