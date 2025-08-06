import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/status_model.dart';
import '../models/salon_model.dart';
import '../models/story_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === USERS ===

  Future<void> createUser(UserModel user) async {
    try {
      await _db
          .collection(Constants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      print('Erreur création utilisateur: $e');
      throw e;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc =
          await _db.collection(Constants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur récupération utilisateur: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _db
          .collection(Constants.usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      print('Erreur mise à jour utilisateur: $e');
      throw e;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection(Constants.usersCollection).doc(uid).delete();
    } catch (e) {
      print('Erreur suppression utilisateur: $e');
      throw e;
    }
  }

  // === VOICE STATUS ===

  Future<String> createVoiceStatus(StatusModel status) async {
    try {
      final docRef = await _db
          .collection(Constants.voiceStatusCollection)
          .add(status.toMap());
      return docRef.id;
    } catch (e) {
      print('Erreur création statut vocal: $e');
      throw e;
    }
  }

  Stream<List<StatusModel>> getVoiceStatusStream() {
    return _db
        .collection(Constants.voiceStatusCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StatusModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> likeStatus(String statusId, String userId) async {
    try {
      final docRef =
          _db.collection(Constants.voiceStatusCollection).doc(statusId);
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          final likes = data['likes'] ?? 0;

          if (!likedBy.contains(userId)) {
            likedBy.add(userId);
            transaction.update(docRef, {
              'likedBy': likedBy,
              'likes': likes + 1,
            });
          }
        }
      });
    } catch (e) {
      print('Erreur like statut: $e');
      throw e;
    }
  }

  // === CHATROOMS ===

  Future<void> initializeDefaultSalons() async {
    try {
      final salonsSnapshot =
          await _db.collection(Constants.chatroomsCollection).get();
      if (salonsSnapshot.docs.isEmpty) {
        final defaultSalons = [
          {
            'name': 'École',
            'icon': '🎓',
            'description': 'Discussions sur l\'école et l\'éducation'
          },
          {
            'name': 'Gbaka',
            'icon': '🚐',
            'description': 'Histoires et anecdotes de transport'
          },
          {
            'name': 'Quartier',
            'icon': '🏘️',
            'description': 'Nouvelles du quartier'
          },
          {
            'name': 'Boulot',
            'icon': '💼',
            'description': 'Discussions professionnelles'
          },
          {'name': 'Sport', 'icon': '⚽', 'description': 'Actualités sportives'},
          {
            'name': 'Musique',
            'icon': '🎵',
            'description': 'Musique et artistes'
          },
          {
            'name': 'Général',
            'icon': '💬',
            'description': 'Discussions générales'
          },
        ];

        final batch = _db.batch();
        for (final salonData in defaultSalons) {
          final salonModel = SalonModel(
            id: '',
            name: salonData['name']!,
            description: salonData['description']!,
            icon: salonData['icon']!,
            createdAt: DateTime.now(),
            lastActivity: DateTime.now(),
          );

          final docRef = _db.collection(Constants.chatroomsCollection).doc();
          batch.set(docRef, salonModel.toMap());
        }

        await batch.commit();
      }
    } catch (e) {
      print('Erreur initialisation salons: $e');
    }
  }

  Stream<List<SalonModel>> getSalonsStream() {
    return _db
        .collection(Constants.chatroomsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SalonModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> joinSalon(String salonId, String userId) async {
    try {
      final docRef = _db.collection(Constants.chatroomsCollection).doc(salonId);
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final participants = List<String>.from(data['participants'] ?? []);

          if (!participants.contains(userId)) {
            participants.add(userId);
            transaction.update(docRef, {
              'participants': participants,
              'participantsCount': participants.length,
              'lastActivity': Timestamp.now(),
            });
          }
        }
      });
    } catch (e) {
      print('Erreur rejoindre salon: $e');
    }
  }

  // === MESSAGES ===

  Future<String> sendMessage(MessageModel message) async {
    try {
      final docRef = await _db
          .collection(Constants.chatroomsCollection)
          .doc(message.salonId)
          .collection(Constants.messagesSubcollection)
          .add(message.toMap());

      // Mettre à jour l'activité du salon
      await _db
          .collection(Constants.chatroomsCollection)
          .doc(message.salonId)
          .update({
        'lastActivity': Timestamp.now(),
      });

      return docRef.id;
    } catch (e) {
      print('Erreur envoi message: $e');
      throw e;
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String salonId) {
    return _db
        .collection(Constants.chatroomsCollection)
        .doc(salonId)
        .collection(Constants.messagesSubcollection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // === MINI STORIES ===

  Future<String> createStory(StoryModel story) async {
    try {
      final docRef = await _db
          .collection(Constants.miniStoriesCollection)
          .add(story.toMap());
      return docRef.id;
    } catch (e) {
      print('Erreur création story: $e');
      throw e;
    }
  }

  Stream<List<StoryModel>> getStoriesStream() {
    return _db
        .collection(Constants.miniStoriesCollection)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StoryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> viewStory(String storyId, String userId) async {
    try {
      final docRef =
          _db.collection(Constants.miniStoriesCollection).doc(storyId);
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final viewedBy = List<String>.from(data['viewedBy'] ?? []);
          final views = data['views'] ?? 0;

          if (!viewedBy.contains(userId)) {
            viewedBy.add(userId);
            transaction.update(docRef, {
              'viewedBy': viewedBy,
              'views': views + 1,
            });
          }
        }
      });
    } catch (e) {
      print('Erreur vue story: $e');
    }
  }

  // === STATISTIQUES ===

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final statusCount = await _db
          .collection(Constants.voiceStatusCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final storiesCount = await _db
          .collection(Constants.miniStoriesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return {
        'statusCount': statusCount.docs.length,
        'storiesCount': storiesCount.docs.length,
      };
    } catch (e) {
      print('Erreur récupération stats: $e');
      return {'statusCount': 0, 'storiesCount': 0};
    }
  }
}
