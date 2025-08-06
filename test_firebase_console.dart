import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/firestore_service.dart';
import 'lib/models/user_model.dart';

void main() async {
  print('=== TESTS FIREBASE CONSOLE ===\n');

  try {
    // Initialisation Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé avec succès\n');

    // Tests d'authentification
    await testAuthentication();

    // Tests Firestore
    await testFirestore();
  } catch (e) {
    print('❌ Erreur d\'initialisation Firebase: $e');
  }
}

Future<void> testAuthentication() async {
  print('--- TESTS AUTHENTIFICATION ---');
  final authService = AuthService();

  // Test 1: Connexion anonyme
  try {
    print('Test 1: Connexion anonyme...');
    final user = await authService.signInAnonymously();
    if (user != null) {
      print('✅ Connexion anonyme réussie - UID: ${user.uid}');
      await authService.signOut();
      print('✅ Déconnexion réussie');
    }
  } catch (e) {
    print('❌ Erreur connexion anonyme: $e');
  }

  // Test 2: Inscription avec email
  try {
    print('\nTest 2: Inscription avec email...');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'test$timestamp@squadci.test';
    final password = 'TestPassword123!';

    print('Email test: $email');
    final user = await authService.registerWithEmail(email, password);
    if (user != null) {
      print('✅ Inscription réussie - UID: ${user.uid}');
      print('Email: ${user.email}');

      // Test 3: Connexion avec le même email
      await authService.signOut();
      print('\nTest 3: Connexion avec email...');
      final loginUser = await authService.signInWithEmail(email, password);
      if (loginUser != null) {
        print('✅ Connexion réussie - UID: ${loginUser.uid}');

        // Nettoyer - supprimer le compte de test
        await authService.deleteAccount();
        print('✅ Compte de test supprimé');
      }
    }
  } catch (e) {
    print('❌ Erreur test inscription/connexion: $e');
  }

  print('');
}

Future<void> testFirestore() async {
  print('--- TESTS FIRESTORE ---');
  final firestoreService = FirestoreService();
  final authService = AuthService();

  try {
    // Créer un utilisateur temporaire pour les tests
    print('Création utilisateur temporaire...');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'firestore$timestamp@squadci.test';
    final password = 'TestPassword123!';

    final user = await authService.registerWithEmail(email, password);
    if (user != null) {
      print('✅ Utilisateur temporaire créé - UID: ${user.uid}');

      // Test création profil Firestore
      print('\nTest: Création profil Firestore...');
      final userModel = UserModel(
        uid: user.uid,
        pseudo: 'TestUser$timestamp',
        email: email,
        quartierPrefere: 'Cocody',
        inscritAt: DateTime.now(),
        isAnonymous: false,
      );

      await firestoreService.createUser(userModel);
      print('✅ Profil Firestore créé');

      // Test récupération profil
      print('\nTest: Récupération profil...');
      final retrievedUser = await firestoreService.getUser(user.uid);
      if (retrievedUser != null) {
        print('✅ Profil récupéré:');
        print('  - Pseudo: ${retrievedUser.pseudo}');
        print('  - Email: ${retrievedUser.email}');
        print('  - Quartier: ${retrievedUser.quartierPrefere}');
        print('  - Inscrit le: ${retrievedUser.inscritAt}');
      } else {
        print('❌ Impossible de récupérer le profil');
      }

      // Test mise à jour profil
      print('\nTest: Mise à jour profil...');
      final updatedUser =
          retrievedUser!.copyWith(pseudo: 'TestUserUpdated$timestamp');
      await firestoreService.updateUser(updatedUser);

      final updatedRetrievedUser = await firestoreService.getUser(user.uid);
      if (updatedRetrievedUser?.pseudo == 'TestUserUpdated$timestamp') {
        print('✅ Profil mis à jour avec succès');
      } else {
        print('❌ Échec mise à jour profil');
      }

      // Nettoyer
      print('\nNettoyage...');
      await firestoreService.deleteUser(user.uid);
      await authService.deleteAccount();
      print('✅ Données de test supprimées');
    } else {
      print('❌ Impossible de créer l\'utilisateur temporaire');
    }
  } catch (e) {
    print('❌ Erreur test Firestore: $e');
  }

  print('');
}
