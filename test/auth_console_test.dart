import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:squad_ci/services/auth_service.dart';
import 'package:squad_ci/providers/auth_provider.dart';
import 'package:squad_ci/firebase_options.dart';

void main() {
  setUpAll(() async {
    // Initialisation Firebase pour les tests
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('Tests Firebase Auth Console', () {
    test('Test connexion anonyme', () async {
      print('=== TEST CONNEXION ANONYME ===');
      final authService = AuthService();

      try {
        final user = await authService.signInAnonymously();
        expect(user, isNotNull);
        print('✅ Connexion anonyme réussie - UID: ${user!.uid}');

        // Nettoyage
        await authService.signOut();
        print('✅ Déconnexion réussie');
      } catch (e) {
        print('❌ Erreur connexion anonyme: $e');
        rethrow;
      }
    });

    test('Test inscription et connexion avec email', () async {
      print('\n=== TEST INSCRIPTION/CONNEXION EMAIL ===');
      final authService = AuthService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'test$timestamp@squadci.test';
      final password = 'TestPassword123!';

      print('📧 Email: $email');
      print('🔒 Mot de passe: $password');

      try {
        // Test inscription
        print('\n🔄 Inscription...');
        final user = await authService.registerWithEmail(email, password);
        expect(user, isNotNull);
        print('✅ Inscription réussie - UID: ${user!.uid}');

        // Test déconnexion
        await authService.signOut();
        print('✅ Déconnexion réussie');

        // Test reconnexion
        print('\n🔄 Reconnexion...');
        final loginUser = await authService.signInWithEmail(email, password);
        expect(loginUser, isNotNull);
        print('✅ Connexion réussie - UID: ${loginUser!.uid}');

        // Nettoyage
        await authService.deleteAccount();
        print('🗑️ Compte de test supprimé');
      } catch (e) {
        print('❌ Erreur test inscription/connexion: $e');
        rethrow;
      }
    });

    test('Test AuthProvider complet', () async {
      print('\n=== TEST AUTH PROVIDER ===');
      final authProvider = AuthProvider();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'provider$timestamp@squadci.test';
      final password = 'TestPassword123!';
      final pseudo = 'TestUser$timestamp';
      final quartier = 'Cocody';

      print('📧 Email: $email');
      print('👤 Pseudo: $pseudo');
      print('📍 Quartier: $quartier');

      try {
        // Test inscription complète
        print('\n🔄 Inscription avec AuthProvider...');
        final success = await authProvider.registerWithEmail(
            email, password, pseudo, quartier);
        expect(success, isTrue);
        print('✅ Inscription AuthProvider réussie');

        if (authProvider.currentUser != null) {
          print('📋 Profil créé:');
          print('  - Pseudo: ${authProvider.currentUser!.pseudo}');
          print('  - Email: ${authProvider.currentUser!.email}');
          print('  - Quartier: ${authProvider.currentUser!.quartierPrefere}');
        }

        // Test déconnexion
        await authProvider.signOut();
        expect(authProvider.isAuthenticated, isFalse);
        print('✅ Déconnexion AuthProvider réussie');

        // Test reconnexion
        print('\n🔄 Reconnexion avec AuthProvider...');
        final loginSuccess =
            await authProvider.signInWithEmail(email, password);
        expect(loginSuccess, isTrue);
        print('✅ Connexion AuthProvider réussie');

        // Nettoyage
        if (authProvider.firebaseUser != null) {
          final authService = AuthService();
          await authService.deleteAccount();
          print('🗑️ Compte AuthProvider supprimé');
        }
      } catch (e) {
        print('❌ Erreur test AuthProvider: $e');
        print('Error message: ${authProvider.errorMessage}');
        rethrow;
      }
    });

    test('Test gestion erreurs Firebase', () async {
      print('\n=== TEST GESTION ERREURS ===');
      final authService = AuthService();

      // Test email invalide
      print('\n🔄 Test email invalide...');
      try {
        await authService.registerWithEmail('email-invalide', 'password123');
        fail('Devrait lever une exception pour email invalide');
      } catch (e) {
        print('✅ Erreur capturée pour email invalide: $e');
        expect(e.toString(), contains('invalide'));
      }

      // Test mot de passe faible
      print('\n🔄 Test mot de passe faible...');
      try {
        await authService.registerWithEmail('test@example.com', '123');
        fail('Devrait lever une exception pour mot de passe faible');
      } catch (e) {
        print('✅ Erreur capturée pour mot de passe faible: $e');
        expect(e.toString(), contains('faible'));
      }

      // Test compte inexistant
      print('\n🔄 Test compte inexistant...');
      try {
        await authService.signInWithEmail('inexistant@test.com', 'password123');
        fail('Devrait lever une exception pour compte inexistant');
      } catch (e) {
        print('✅ Erreur capturée pour compte inexistant: $e');
        expect(e.toString(), contains('trouvé'));
      }
    });

    test('Test email déjà utilisé', () async {
      print('\n=== TEST EMAIL DÉJÀ UTILISÉ ===');
      final authService = AuthService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'duplicate$timestamp@test.com';
      final password = 'ValidPassword123!';

      try {
        // Première inscription
        print('🔄 Première inscription...');
        final user1 = await authService.registerWithEmail(email, password);
        expect(user1, isNotNull);
        print('✅ Premier compte créé: ${user1!.uid}');

        // Deuxième inscription avec le même email
        print('🔄 Tentative de duplication...');
        try {
          await authService.registerWithEmail(email, password);
          fail('Devrait lever une exception pour email déjà utilisé');
        } catch (e) {
          print('✅ Erreur capturée pour email déjà utilisé: $e');
          expect(e.toString(), contains('existe'));
        }

        // Nettoyage
        await authService.deleteAccount();
        print('🗑️ Compte de test supprimé');
      } catch (e) {
        print('❌ Erreur dans test duplicate: $e');
        rethrow;
      }
    });
  });
}
