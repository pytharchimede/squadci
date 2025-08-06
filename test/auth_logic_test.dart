import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tests logique Auth (sans Firebase)', () {
    test('Test validation email', () {
      print('=== TEST VALIDATION EMAIL ===');

      // Emails valides
      final validEmails = [
        'test@example.com',
        'user.name@domain.co',
        'user+tag@example.org',
      ];

      // Emails invalides
      final invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        'user@.com',
        '',
      ];

      for (final email in validEmails) {
        final isValid = _isValidEmail(email);
        print('✅ $email -> valide: $isValid');
        expect(isValid, isTrue, reason: 'Email $email devrait être valide');
      }

      for (final email in invalidEmails) {
        final isValid = _isValidEmail(email);
        print('❌ $email -> valide: $isValid');
        expect(isValid, isFalse, reason: 'Email $email devrait être invalide');
      }
    });

    test('Test validation mot de passe', () {
      print('\n=== TEST VALIDATION MOT DE PASSE ===');

      final passwords = [
        {
          'password': 'abc',
          'expected': 1,
          'reason': 'Trop court, mais minuscules'
        },
        {
          'password': 'password',
          'expected': 2,
          'reason': '8+ caractères, minuscules'
        },
        {
          'password': 'Password',
          'expected': 3,
          'reason': '8+ caractères, minuscules, majuscules'
        },
        {
          'password': 'Password123',
          'expected': 4,
          'reason': '8+ caractères, minuscules, majuscules, chiffres'
        },
        {
          'password': 'Password123!',
          'expected': 5,
          'reason': 'Tous les critères'
        },
        {
          'password': 'Pass123!',
          'expected': 5,
          'reason': 'Tous les critères remplis'
        },
      ];

      for (final test in passwords) {
        final password = test['password'] as String;
        final expected = test['expected'] as int;
        final reason = test['reason'] as String;

        final strength = _calculatePasswordStrength(password);
        print('🔒 "$password" -> force: $strength/5 ($reason)');
        expect(strength, equals(expected),
            reason: 'Force incorrecte pour: $password');
      }
    });

    test('Test AuthProvider sans Firebase', () {
      print('\n=== TEST AUTH PROVIDER LOGIQUE ===');

      // Test des validations locales
      print('🔄 Test validations locales...');

      // Test validation formulaire vide
      final isFormValid1 = _isSignupFormValid('', '', '', '');
      print('❌ Formulaire vide -> valide: $isFormValid1');
      expect(isFormValid1, isFalse);

      // Test mots de passe différents
      final isFormValid2 = _isSignupFormValid(
          'test@example.com', 'TestUser', 'Password123!', 'DifferentPassword');
      print('❌ Mots de passe différents -> valide: $isFormValid2');
      expect(isFormValid2, isFalse);

      // Test mot de passe faible
      final isFormValid3 =
          _isSignupFormValid('test@example.com', 'TestUser', 'weak', 'weak');
      print('❌ Mot de passe faible -> valide: $isFormValid3');
      expect(isFormValid3, isFalse);

      // Test formulaire valide
      final isFormValid4 = _isSignupFormValid(
          'test@example.com', 'TestUser', 'Password123!', 'Password123!');
      print('✅ Formulaire valide -> valide: $isFormValid4');
      expect(isFormValid4, isTrue);
    });

    test('Test messages d\'erreur Firebase simulés', () {
      print('\n=== TEST MESSAGES ERREUR ===');

      final errorCodes = {
        'weak-password': 'Le mot de passe est trop faible.',
        'email-already-in-use': 'Un compte existe déjà avec cet email.',
        'invalid-email': 'Format d\'email invalide.',
        'user-not-found': 'Aucun utilisateur trouvé avec cet email.',
        'wrong-password': 'Mot de passe incorrect.',
        'too-many-requests': 'Trop de tentatives. Réessayez plus tard.',
      };

      for (final entry in errorCodes.entries) {
        final code = entry.key;
        final expectedMessage = entry.value;
        final actualMessage = _getFirebaseErrorMessage(code);

        print('🔥 $code -> $actualMessage');
        expect(actualMessage, equals(expectedMessage));
      }
    });
  });
}

// Fonctions utilitaires pour les tests
bool _isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

int _calculatePasswordStrength(String password) {
  int criteriaCount = 0;
  if (password.length >= 8) criteriaCount++;
  if (password.contains(RegExp(r'[A-Z]'))) criteriaCount++;
  if (password.contains(RegExp(r'[a-z]'))) criteriaCount++;
  if (password.contains(RegExp(r'[0-9]'))) criteriaCount++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) criteriaCount++;
  return criteriaCount;
}

bool _isSignupFormValid(
    String email, String pseudo, String password, String confirmPassword) {
  // Vérifier que les champs ne sont pas vides
  if (email.trim().isEmpty ||
      pseudo.trim().isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    return false;
  }

  // Vérifier que les mots de passe correspondent
  if (password != confirmPassword) {
    return false;
  }

  // Vérifier la force du mot de passe (au moins 3 critères sur 5)
  int criteriaCount = _calculatePasswordStrength(password);
  return criteriaCount >= 3;
}

String _getFirebaseErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'weak-password':
      return 'Le mot de passe est trop faible.';
    case 'email-already-in-use':
      return 'Un compte existe déjà avec cet email.';
    case 'invalid-email':
      return 'Format d\'email invalide.';
    case 'user-not-found':
      return 'Aucun utilisateur trouvé avec cet email.';
    case 'wrong-password':
      return 'Mot de passe incorrect.';
    case 'too-many-requests':
      return 'Trop de tentatives. Réessayez plus tard.';
    default:
      return 'Erreur inconnue: $errorCode';
  }
}
