import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthTestAPI {
  static final AuthService _authService = AuthService();
  static final FirestoreService _firestoreService = FirestoreService();

  static Future<void> testAuthService() async {
    print('\n=== TEST AUTH SERVICE ===');

    // Test 1: Connexion anonyme
    print('\n--- Test 1: Connexion anonyme ---');
    try {
      final user = await _authService.signInAnonymously();
      if (user != null) {
        print('✅ Connexion anonyme réussie');
        print('   UID: ${user.uid}');
        print('   Is Anonymous: ${user.isAnonymous}');

        await _authService.signOut();
        print('✅ Déconnexion réussie');
      } else {
        print('❌ Connexion anonyme échouée - user null');
      }
    } catch (e) {
      print('❌ Erreur connexion anonyme: $e');
    }

    // Test 2: Inscription avec email
    print('\n--- Test 2: Inscription avec email ---');
    String testEmail =
        'authtest${DateTime.now().millisecondsSinceEpoch}@squadci.com';
    String testPassword = 'SquadCITest123!';

    try {
      final user =
          await _authService.registerWithEmail(testEmail, testPassword);
      if (user != null) {
        print('✅ Inscription réussie');
        print('   UID: ${user.uid}');
        print('   Email: ${user.email}');

        // Test 3: Connexion avec email
        await _authService.signOut();
        print('\n--- Test 3: Connexion avec email ---');

        final loginUser =
            await _authService.signInWithEmail(testEmail, testPassword);
        if (loginUser != null) {
          print('✅ Connexion avec email réussie');
          print('   UID: ${loginUser.uid}');

          // Nettoyage
          await loginUser.delete();
          print('✅ Compte test supprimé');
        } else {
          print('❌ Connexion avec email échouée');
        }
      } else {
        print('❌ Inscription échouée - user null');
      }
    } catch (e) {
      print('❌ Erreur inscription/connexion: $e');
    }
  }

  static Future<void> testFirestoreService() async {
    print('\n=== TEST FIRESTORE SERVICE ===');

    try {
      // Créer un utilisateur test
      final testUser = UserModel(
        uid: 'test_${DateTime.now().millisecondsSinceEpoch}',
        pseudo: 'TestUser',
        email: 'test@squadci.com',
        quartierPrefere: 'Cocody',
        inscritAt: DateTime.now(),
        isAnonymous: false,
      );

      print('\n--- Test création utilisateur ---');
      await _firestoreService.createUser(testUser);
      print('✅ Utilisateur créé dans Firestore');

      print('\n--- Test récupération utilisateur ---');
      final retrievedUser = await _firestoreService.getUser(testUser.uid);
      if (retrievedUser != null) {
        print('✅ Utilisateur récupéré avec succès');
        print('   UID: ${retrievedUser.uid}');
        print('   Pseudo: ${retrievedUser.pseudo}');
        print('   Email: ${retrievedUser.email}');
      } else {
        print('❌ Utilisateur non trouvé');
      }

      print('\n--- Test mise à jour utilisateur ---');
      final updatedUser = UserModel(
        uid: testUser.uid,
        pseudo: 'TestUserModified',
        email: testUser.email,
        quartierPrefere: testUser.quartierPrefere,
        inscritAt: testUser.inscritAt,
        isAnonymous: testUser.isAnonymous,
      );
      await _firestoreService.updateUser(updatedUser);
      print('✅ Utilisateur mis à jour');

      // Vérification de la mise à jour
      final verifiedUser = await _firestoreService.getUser(testUser.uid);
      if (verifiedUser != null && verifiedUser.pseudo == 'TestUserModified') {
        print('✅ Mise à jour vérifiée');
      } else {
        print('❌ Mise à jour non vérifiée');
      }

      // Nettoyage (suppression manuelle car pas de méthode delete dans le service)
      print('\n--- Nettoyage ---');
      // Note: Il faudrait ajouter une méthode deleteUser dans FirestoreService
      print('⚠️ Nettoyage manuel requis pour l\'utilisateur: ${testUser.uid}');
    } catch (e) {
      print('❌ Erreur test Firestore Service: $e');
    }
  }

  static Future<void> testCompleteRegistrationFlow() async {
    print('\n=== TEST FLUX COMPLET D\'INSCRIPTION ===');

    String testEmail =
        'complete_test${DateTime.now().millisecondsSinceEpoch}@squadci.com';
    String testPassword = 'CompleteTest123!';
    String testPseudo = 'CompleteTestUser';
    String testQuartier = 'Yopougon';

    print('Test avec:');
    print('  Email: $testEmail');
    print('  Pseudo: $testPseudo');
    print('  Quartier: $testQuartier');

    try {
      print('\n--- Étape 1: Création compte Firebase Auth ---');
      final user =
          await _authService.registerWithEmail(testEmail, testPassword);

      if (user != null) {
        print('✅ Compte Firebase Auth créé');
        print('   UID: ${user.uid}');

        print('\n--- Étape 2: Création profil Firestore ---');
        final userModel = UserModel(
          uid: user.uid,
          pseudo: testPseudo,
          email: testEmail,
          quartierPrefere: testQuartier,
          inscritAt: DateTime.now(),
          isAnonymous: false,
        );

        await _firestoreService.createUser(userModel);
        print('✅ Profil Firestore créé');

        print('\n--- Étape 3: Vérification profil ---');
        final retrievedUser = await _firestoreService.getUser(user.uid);
        if (retrievedUser != null) {
          print('✅ Profil vérifié');
          print('   Pseudo: ${retrievedUser.pseudo}');
          print('   Quartier: ${retrievedUser.quartierPrefere}');
        } else {
          print('❌ Profil non trouvé');
        }

        print('\n--- Étape 4: Test connexion ---');
        await _authService.signOut();
        final loginUser =
            await _authService.signInWithEmail(testEmail, testPassword);

        if (loginUser != null) {
          print('✅ Connexion après inscription réussie');

          // Nettoyage
          await loginUser.delete();
          print('✅ Compte test supprimé');
        } else {
          print('❌ Connexion après inscription échouée');
        }
      } else {
        print('❌ Création compte Firebase Auth échouée');
      }
    } catch (e) {
      print('❌ Erreur flux complet: $e');
    }
  }

  static Future<void> testAuthProvider() async {
    print('\n=== TEST AUTH PROVIDER ===');

    try {
      final authProvider = AuthProvider();

      String testEmail =
          'provider_test${DateTime.now().millisecondsSinceEpoch}@squadci.com';
      String testPassword = 'ProviderTest123!';
      String testPseudo = 'ProviderTestUser';
      String testQuartier = 'Adjamé';

      print('Test AuthProvider avec:');
      print('  Email: $testEmail');
      print('  Pseudo: $testPseudo');

      print('\n--- Test inscription via AuthProvider ---');
      final success = await authProvider.registerWithEmail(
        testEmail,
        testPassword,
        testPseudo,
        testQuartier,
      );

      if (success) {
        print('✅ Inscription via AuthProvider réussie');
        print('   User: ${authProvider.currentUser?.pseudo}');
        print('   Email: ${authProvider.currentUser?.email}');
        print('   Quartier: ${authProvider.currentUser?.quartierPrefere}');
      } else {
        print('❌ Inscription via AuthProvider échouée');
        print('   Erreur: ${authProvider.errorMessage}');
      }

      // Test connexion
      await authProvider.signOut();
      print('\n--- Test connexion via AuthProvider ---');

      final loginSuccess =
          await authProvider.signInWithEmail(testEmail, testPassword);
      if (loginSuccess) {
        print('✅ Connexion via AuthProvider réussie');
      } else {
        print('❌ Connexion via AuthProvider échouée');
        print('   Erreur: ${authProvider.errorMessage}');
      }
    } catch (e) {
      print('❌ Erreur test AuthProvider: $e');
    }
  }

  static Future<void> runAllAuthTests() async {
    print('🚀 DÉBUT DES TESTS AUTH API\n');

    await testAuthService();
    await testFirestoreService();
    await testCompleteRegistrationFlow();
    await testAuthProvider();

    print('\n🏁 FIN DES TESTS AUTH API');
  }
}
