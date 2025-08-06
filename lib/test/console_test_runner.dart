import 'firebase_test.dart';
import 'auth_test.dart';

class ConsoleTestRunner {
  static Future<void> runAllTests() async {
    print('🎯 SQUAD CI - TESTS API CONSOLE');
    print('================================\n');

    try {
      // Tests Firebase de base
      await FirebaseTestAPI.runAllTests();

      print('\n' + '=' * 50 + '\n');

      // Tests spécifiques à l'authentification
      await AuthTestAPI.runAllAuthTests();

      print('\n' + '=' * 50);
      print('✅ TOUS LES TESTS TERMINÉS');
      print('================================');
    } catch (e) {
      print('\n' + '=' * 50);
      print('❌ ERREUR GÉNÉRALE DANS LES TESTS');
      print('Erreur: $e');
      print('================================');
    }
  }

  static Future<void> runBasicFirebaseTests() async {
    print('🔥 TESTS FIREBASE DE BASE');
    print('=========================\n');

    await FirebaseTestAPI.runAllTests();
  }

  static Future<void> runAuthTests() async {
    print('🔐 TESTS AUTHENTIFICATION');
    print('=========================\n');

    await AuthTestAPI.runAllAuthTests();
  }

  static Future<void> runQuickTest() async {
    print('⚡ TEST RAPIDE - CONNEXION FIREBASE');
    print('===================================\n');

    await FirebaseTestAPI.initializeFirebase();
    await FirebaseTestAPI.testFirebaseAuth();
  }

  static void logSeparator() {
    print('\n' + '-' * 50 + '\n');
  }

  static void logHeader(String title) {
    print('\n' + '=' * 50);
    print('  $title');
    print('=' * 50 + '\n');
  }

  static void logSuccess(String message) {
    print('✅ $message');
  }

  static void logError(String message) {
    print('❌ $message');
  }

  static void logInfo(String message) {
    print('ℹ️  $message');
  }

  static void logWarning(String message) {
    print('⚠️  $message');
  }
}
