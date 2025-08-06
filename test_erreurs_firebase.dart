import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/auth_service.dart';

void main() async {
  print('=== TEST ERREURS FIREBASE ===\n');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé\n');

    final authService = AuthService();

    // Test 1: Email invalide
    print('--- TEST 1: EMAIL INVALIDE ---');
    try {
      await authService.registerWithEmail('email-invalide', 'password123');
    } catch (e) {
      print('✅ Erreur capturée pour email invalide: $e\n');
    }

    // Test 2: Mot de passe trop faible
    print('--- TEST 2: MOT DE PASSE FAIBLE ---');
    try {
      await authService.registerWithEmail('test@example.com', '123');
    } catch (e) {
      print('✅ Erreur capturée pour mot de passe faible: $e\n');
    }

    // Test 3: Créer un compte puis essayer de le recréer
    print('--- TEST 3: EMAIL DÉJÀ UTILISÉ ---');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'duplicate$timestamp@test.com';
    final password = 'ValidPassword123!';

    try {
      // Première inscription
      final user1 = await authService.registerWithEmail(email, password);
      print('✅ Premier compte créé: ${user1?.uid}');

      // Deuxième inscription avec le même email
      try {
        await authService.registerWithEmail(email, password);
        print('❌ ERREUR: Le deuxième compte a été créé !');
      } catch (e) {
        print('✅ Erreur capturée pour email déjà utilisé: $e');
      }

      // Nettoyage
      if (user1 != null) {
        await authService.deleteAccount();
        print('🗑️ Compte de test supprimé');
      }
    } catch (e) {
      print('❌ Erreur dans test duplicate: $e');
    }

    print('');

    // Test 4: Connexion avec compte inexistant
    print('--- TEST 4: COMPTE INEXISTANT ---');
    try {
      await authService.signInWithEmail('inexistant@test.com', 'password123');
    } catch (e) {
      print('✅ Erreur capturée pour compte inexistant: $e\n');
    }

    // Test 5: Connexion avec mauvais mot de passe
    print('--- TEST 5: MAUVAIS MOT DE PASSE ---');
    final emailTest = 'testpassword$timestamp@test.com';
    try {
      // Créer un compte
      final user = await authService.registerWithEmail(emailTest, password);
      print('✅ Compte créé pour test mot de passe');

      // Se déconnecter
      await authService.signOut();

      // Essayer de se connecter avec un mauvais mot de passe
      try {
        await authService.signInWithEmail(emailTest, 'MauvaisMotDePasse');
      } catch (e) {
        print('✅ Erreur capturée pour mauvais mot de passe: $e');
      }

      // Nettoyage
      await authService.signInWithEmail(emailTest, password);
      await authService.deleteAccount();
      print('🗑️ Compte de test supprimé');
    } catch (e) {
      print('❌ Erreur dans test mauvais mot de passe: $e');
    }

    print('\n=== FIN DES TESTS ===');
  } catch (e) {
    print('❌ Erreur d\'initialisation: $e');
  }
}
