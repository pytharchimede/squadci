import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Connexion anonyme
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur connexion anonyme: ${e.code}');
      switch (e.code) {
        case 'operation-not-allowed':
          throw 'Connexion anonyme non autorisée.';
        case 'too-many-requests':
          throw 'Trop de tentatives. Réessayez plus tard.';
        default:
          throw 'Erreur de connexion anonyme: ${e.message}';
      }
    } catch (e) {
      print('Erreur connexion anonyme: $e');
      throw 'Erreur de connexion anonyme: $e';
    }
  }

  // Connexion avec email/mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur connexion email: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          throw 'Mot de passe incorrect.';
        case 'invalid-email':
          throw 'Format d\'email invalide.';
        case 'user-disabled':
          throw 'Ce compte a été désactivé.';
        case 'too-many-requests':
          throw 'Trop de tentatives. Réessayez plus tard.';
        default:
          throw 'Erreur de connexion: ${e.message}';
      }
    } catch (e) {
      print('Erreur connexion email: $e');
      throw 'Erreur de connexion: $e';
    }
  }

  // Inscription avec email/mot de passe
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur inscription: ${e.code}');
      switch (e.code) {
        case 'weak-password':
          throw 'Le mot de passe est trop faible.';
        case 'email-already-in-use':
          throw 'Un compte existe déjà avec cet email.';
        case 'invalid-email':
          throw 'Format d\'email invalide.';
        case 'operation-not-allowed':
          throw 'Inscription non autorisée.';
        case 'too-many-requests':
          throw 'Trop de tentatives. Réessayez plus tard.';
        default:
          throw 'Erreur d\'inscription: ${e.message}';
      }
    } catch (e) {
      print('Erreur inscription: $e');
      throw 'Erreur d\'inscription: $e';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur déconnexion: $e');
      throw e;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur réinitialisation mot de passe: $e');
      throw e;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      print('Erreur mise à jour profil: $e');
      throw e;
    }
  }

  // Supprimer le compte utilisateur
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('Erreur suppression compte: $e');
      throw e;
    }
  }
}
