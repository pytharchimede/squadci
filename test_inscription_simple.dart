import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/firestore_service.dart';
import 'lib/providers/auth_provider.dart';
import 'lib/models/user_model.dart';

void main() async {
  print('=== TESTS RAPIDES INSCRIPTION/CONNEXION ===\n');

  try {
    // Initialisation Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé\n');

    // Paramètres de test
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'user$timestamp@squadci.test';
    final password = 'MotDePasse123!';
    final pseudo = 'TestUser$timestamp';
    final quartier = 'Cocody';

    print('📧 Email: $email');
    print('🔒 Mot de passe: $password');
    print('👤 Pseudo: $pseudo');
    print('📍 Quartier: $quartier\n');

    // Test avec AuthProvider (comme dans l'app)
    await testWithAuthProvider(email, password, pseudo, quartier);

    // Test direct avec les services
    await testDirectServices(email, password, pseudo, quartier);
  } catch (e) {
    print('❌ Erreur d\'initialisation: $e');
  }
}

Future<void> testWithAuthProvider(
    String email, String password, String pseudo, String quartier) async {
  print('--- TEST AVEC AUTH PROVIDER ---');

  final authProvider = AuthProvider();

  try {
    print('🔄 Inscription en cours...');
    final success =
        await authProvider.registerWithEmail(email, password, pseudo, quartier);

    if (success) {
      print('✅ Inscription réussie !');
      print('👤 Utilisateur connecté: ${authProvider.firebaseUser?.uid}');

      if (authProvider.currentUser != null) {
        print('📋 Profil chargé:');
        print('  - Pseudo: ${authProvider.currentUser!.pseudo}');
        print('  - Email: ${authProvider.currentUser!.email}');
        print('  - Quartier: ${authProvider.currentUser!.quartierPrefere}');
      }

      // Test de déconnexion
      print('\n🔄 Déconnexion...');
      await authProvider.signOut();
      print('✅ Déconnexion réussie');

      // Test de reconnexion
      print('\n🔄 Reconnexion...');
      final loginSuccess = await authProvider.signInWithEmail(email, password);
      if (loginSuccess) {
        print('✅ Connexion réussie !');
        print('👤 Utilisateur connecté: ${authProvider.firebaseUser?.uid}');
      } else {
        print('❌ Échec de la connexion');
        print('Error: ${authProvider.errorMessage}');
      }

      // Nettoyage
      if (authProvider.firebaseUser != null) {
        final authService = AuthService();
        await authService.deleteAccount();
        print('🗑️ Compte de test supprimé');
      }
    } else {
      print('❌ Échec de l\'inscription');
      print('Error: ${authProvider.errorMessage}');
    }
  } catch (e) {
    print('❌ Erreur dans testWithAuthProvider: $e');
  }

  print('');
}

Future<void> testDirectServices(
    String email, String password, String pseudo, String quartier) async {
  print('--- TEST DIRECT AVEC SERVICES ---');

  final authService = AuthService();
  final firestoreService = FirestoreService();

  try {
    // Inscription Firebase Auth
    print('🔄 Inscription Firebase Auth...');
    final user =
        await authService.registerWithEmail(email + '.direct', password);

    if (user != null) {
      print('✅ Inscription Firebase réussie - UID: ${user.uid}');

      // Création profil Firestore
      print('🔄 Création profil Firestore...');
      final userModel = UserModel(
        uid: user.uid,
        pseudo: pseudo + 'Direct',
        email: email + '.direct',
        quartierPrefere: quartier,
        inscritAt: DateTime.now(),
        isAnonymous: false,
      );

      await firestoreService.createUser(userModel);
      print('✅ Profil Firestore créé');

      // Test récupération
      print('🔄 Récupération profil...');
      final retrievedUser = await firestoreService.getUser(user.uid);
      if (retrievedUser != null) {
        print('✅ Profil récupéré:');
        print('  - Pseudo: ${retrievedUser.pseudo}');
        print('  - Email: ${retrievedUser.email}');
      }

      // Test connexion
      print('\n🔄 Test connexion...');
      await authService.signOut();
      final loginUser =
          await authService.signInWithEmail(email + '.direct', password);
      if (loginUser != null) {
        print('✅ Connexion directe réussie');
      }

      // Nettoyage
      await firestoreService.deleteUser(user.uid);
      await authService.deleteAccount();
      print('🗑️ Données supprimées');
    } else {
      print('❌ Échec inscription Firebase Auth');
    }
  } catch (e) {
    print('❌ Erreur dans testDirectServices: $e');
  }

  print('');
}
