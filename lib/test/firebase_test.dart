import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseTestAPI {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialisé avec succès');
    } catch (e) {
      print('❌ Erreur initialisation Firebase: $e');
    }
  }

  static Future<void> testFirebaseAuth() async {
    print('\n=== TEST FIREBASE AUTH ===');

    try {
      final auth = FirebaseAuth.instance;
      print('✅ FirebaseAuth instance créée');

      // Test de connexion anonyme
      print('\n--- Test connexion anonyme ---');
      try {
        final userCredential = await auth.signInAnonymously();
        if (userCredential.user != null) {
          print('✅ Connexion anonyme réussie');
          print('   User ID: ${userCredential.user!.uid}');
          print('   Is Anonymous: ${userCredential.user!.isAnonymous}');

          // Déconnexion
          await auth.signOut();
          print('✅ Déconnexion réussie');
        }
      } catch (e) {
        print('❌ Erreur connexion anonyme: $e');
      }

      // Test d'inscription
      print('\n--- Test inscription ---');
      String testEmail =
          'test${DateTime.now().millisecondsSinceEpoch}@example.com';
      String testPassword = 'TestPassword123!';

      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        if (userCredential.user != null) {
          print('✅ Inscription réussie');
          print('   User ID: ${userCredential.user!.uid}');
          print('   Email: ${userCredential.user!.email}');

          // Test de connexion
          await auth.signOut();
          print('✅ Déconnexion après inscription');

          print('\n--- Test connexion avec email ---');
          final loginCredential = await auth.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          if (loginCredential.user != null) {
            print('✅ Connexion avec email réussie');
            print('   User ID: ${loginCredential.user!.uid}');
          }

          // Nettoyage - suppression du compte test
          await loginCredential.user!.delete();
          print('✅ Compte test supprimé');
        }
      } catch (e) {
        print('❌ Erreur inscription/connexion: $e');
      }
    } catch (e) {
      print('❌ Erreur générale Firebase Auth: $e');
    }
  }

  static Future<void> testFirestore() async {
    print('\n=== TEST FIRESTORE ===');

    try {
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore instance créée');

      // Test d'écriture
      print('\n--- Test écriture Firestore ---');
      String testDocId = 'test_${DateTime.now().millisecondsSinceEpoch}';

      try {
        await firestore.collection('test').doc(testDocId).set({
          'message': 'Test depuis Flutter Web',
          'timestamp': FieldValue.serverTimestamp(),
          'created_at': DateTime.now().toIso8601String(),
        });
        print('✅ Document créé avec succès');
        print('   Document ID: $testDocId');

        // Test de lecture
        print('\n--- Test lecture Firestore ---');
        final doc = await firestore.collection('test').doc(testDocId).get();

        if (doc.exists) {
          print('✅ Document lu avec succès');
          print('   Data: ${doc.data()}');

          // Nettoyage - suppression du document test
          await firestore.collection('test').doc(testDocId).delete();
          print('✅ Document test supprimé');
        } else {
          print('❌ Document non trouvé');
        }
      } catch (e) {
        print('❌ Erreur Firestore: $e');
      }
    } catch (e) {
      print('❌ Erreur générale Firestore: $e');
    }
  }

  static Future<void> testUserCreation() async {
    print('\n=== TEST CRÉATION UTILISATEUR COMPLET ===');

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      String testEmail =
          'squadci_test${DateTime.now().millisecondsSinceEpoch}@example.com';
      String testPassword = 'SquadCI123!';
      String testPseudo = 'TestUser${DateTime.now().millisecondsSinceEpoch}';

      print('Email test: $testEmail');
      print('Pseudo test: $testPseudo');

      // 1. Créer l'utilisateur Firebase Auth
      print('\n--- Étape 1: Création compte Firebase Auth ---');
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      if (userCredential.user != null) {
        print('✅ Compte Firebase Auth créé');
        print('   UID: ${userCredential.user!.uid}');

        // 2. Créer le profil Firestore
        print('\n--- Étape 2: Création profil Firestore ---');
        final userData = {
          'uid': userCredential.user!.uid,
          'pseudo': testPseudo,
          'email': testEmail,
          'quartierPrefere': 'Cocody',
          'inscritAt': FieldValue.serverTimestamp(),
          'isAnonymous': false,
          'created_at': DateTime.now().toIso8601String(),
        };

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);
        print('✅ Profil Firestore créé');

        // 3. Vérifier la création
        print('\n--- Étape 3: Vérification ---');
        final userDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          print('✅ Profil utilisateur vérifié');
          print('   Data: ${userDoc.data()}');
        } else {
          print('❌ Profil utilisateur non trouvé');
        }

        // 4. Nettoyage
        print('\n--- Étape 4: Nettoyage ---');
        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .delete();
        await userCredential.user!.delete();
        print('✅ Utilisateur test supprimé');
      } else {
        print('❌ Échec création compte Firebase Auth');
      }
    } catch (e) {
      print('❌ Erreur création utilisateur complet: $e');
      if (e is FirebaseAuthException) {
        print('   Code erreur: ${e.code}');
        print('   Message: ${e.message}');
      }
    }
  }

  static Future<void> runAllTests() async {
    print('🚀 DÉBUT DES TESTS FIREBASE API\n');

    await initializeFirebase();
    await testFirebaseAuth();
    await testFirestore();
    await testUserCreation();

    print('\n🏁 FIN DES TESTS FIREBASE API');
  }
}
