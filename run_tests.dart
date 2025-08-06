import 'dart:io';

void main() async {
  print('=== LAUNCHER TESTS FIREBASE ===\n');

  print('Choisissez le test à exécuter:');
  print('1. Test complet Firebase (auth + firestore)');
  print('2. Test simple inscription/connexion');
  print('3. Test gestion d\'erreurs Firebase');
  print('4. Tous les tests');
  print('\nEntrez votre choix (1-4): ');

  final input = stdin.readLineSync();

  switch (input) {
    case '1':
      print('\n🚀 Lancement du test complet...\n');
      await Process.run('dart', ['test_firebase_console.dart'],
          workingDirectory: Directory.current.path);
      break;

    case '2':
      print('\n🚀 Lancement du test simple...\n');
      await Process.run('dart', ['test_inscription_simple.dart'],
          workingDirectory: Directory.current.path);
      break;

    case '3':
      print('\n🚀 Lancement du test d\'erreurs...\n');
      await Process.run('dart', ['test_erreurs_firebase.dart'],
          workingDirectory: Directory.current.path);
      break;

    case '4':
      print('\n🚀 Lancement de tous les tests...\n');

      print('--- TEST COMPLET ---');
      await Process.run('dart', ['test_firebase_console.dart'],
          workingDirectory: Directory.current.path);

      print('\n--- TEST SIMPLE ---');
      await Process.run('dart', ['test_inscription_simple.dart'],
          workingDirectory: Directory.current.path);

      print('\n--- TEST ERREURS ---');
      await Process.run('dart', ['test_erreurs_firebase.dart'],
          workingDirectory: Directory.current.path);
      break;

    default:
      print('❌ Choix invalide. Arrêt du programme.');
  }
}
