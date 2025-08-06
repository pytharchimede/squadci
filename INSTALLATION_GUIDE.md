# Guide d'Installation et de Configuration - SQUAD CI

## 🚀 Guide complet pour démarrer SQUAD CI

### Étape 1 : Prérequis système

#### Installation de Flutter

1. Télécharger Flutter SDK depuis [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extraire l'archive dans un dossier (ex: `C:\tools\flutter`)
3. Ajouter `C:\tools\flutter\bin` au PATH système
4. Vérifier l'installation :

```bash
flutter doctor
```

#### Outils de développement

- **Android Studio** : Pour l'émulation Android et les outils SDK
- **VS Code** : Avec l'extension Flutter (recommandé)
- **Git** : Pour la gestion de version

#### SDK et outils

- Android SDK (API 30+)
- Java JDK 11 ou supérieur
- Chrome (pour le développement web)

### Étape 2 : Configuration du projet

#### Cloner et installer

```bash
# Cloner le projet
git clone <repository-url>
cd squad_ci

# Installer les dépendances
flutter pub get

# Nettoyer et rebuild si nécessaire
flutter clean
flutter pub get
```

#### Vérifier la configuration

```bash
# Vérifier les appareils disponibles
flutter devices

# Vérifier l'état de Flutter
flutter doctor -v
```

### Étape 3 : Configuration Firebase

#### Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un nouveau projet "SQUAD CI"
3. Activer Google Analytics (optionnel)

#### Configuration Android

1. Dans Firebase Console, ajouter une app Android
2. Package name : `com.squadci.app`
3. Télécharger `google-services.json`
4. Placer le fichier dans `android/app/google-services.json`

#### Configuration des services Firebase

1. **Authentication** :

   - Activer l'authentification anonyme
   - Activer l'authentification par email/mot de passe

2. **Firestore Database** :

   - Créer une base de données en mode test
   - Région : europe-west3 (Frankfurt) - proche de l'Afrique

3. **Storage** :
   - Activer Firebase Storage
   - Configurer les règles de sécurité

#### Règles Firestore (mode développement)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles temporaires pour le développement
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### Règles Storage (mode développement)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Étape 4 : Configuration de l'environnement de développement

#### Android Studio

1. Ouvrir Android Studio
2. Tools > AVD Manager
3. Créer un émulateur Android (API 30+, RAM 4GB+)
4. Démarrer l'émulateur

#### VS Code (recommandé)

1. Installer l'extension Flutter
2. Installer l'extension Dart
3. Ouvrir le projet SQUAD CI
4. Cmd/Ctrl + Shift + P > "Flutter: Select Device"

### Étape 5 : Lancement de l'application

#### Première compilation

```bash
# Lancer en mode debug sur l'émulateur
flutter run

# Lancer sur Chrome (développement web)
flutter run -d chrome

# Lancer en mode release
flutter run --release
```

#### Résolution des problèmes courants

**Erreur gradle** :

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Erreur de permissions** :

```bash
# Windows
flutter doctor --android-licenses

# Accepter toutes les licences
```

**Cache corrupted** :

```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Étape 6 : Configuration des permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### Étape 7 : Tests et debugging

#### Tests unitaires

```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage
```

#### Debugging

```bash
# Mode debug avec hot reload
flutter run --debug

# Profiling de performance
flutter run --profile

# Analyse statique du code
flutter analyze
```

### Étape 8 : Build de production

#### Android APK

```bash
# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

#### Web

```bash
# Build web
flutter build web

# Test local
flutter run -d chrome --web-renderer html
```

### Étape 9 : Configuration avancée

#### Icônes et splash screen

1. Remplacer `android/app/src/main/res/mipmap-*/ic_launcher.png`
2. Modifier `android/app/src/main/res/drawable/launch_background.xml`

#### Signature Android (production)

1. Créer un keystore :

```bash
keytool -genkey -v -keystore squad-ci-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias squadci
```

2. Configurer `android/key.properties`
3. Modifier `android/app/build.gradle`

### Étape 10 : Déploiement

#### Google Play Store

1. Créer un compte développeur Google Play
2. Build App Bundle : `flutter build appbundle --release`
3. Upload sur Google Play Console
4. Remplir les métadonnées et captures d'écran

#### Firebase Hosting (Web)

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Login Firebase
firebase login

# Initialiser le projet
firebase init hosting

# Deploy
firebase deploy --only hosting
```

## 🔧 Troubleshooting

### Problèmes fréquents

#### Flutter Doctor Issues

- **Android toolchain** : Installer Android Studio et SDK
- **VS Code extension** : Redémarrer VS Code après installation
- **Device connectivity** : Vérifier l'émulateur ou le câble USB

#### Build Errors

- **Gradle sync failed** : Nettoyer le cache Android Studio
- **Dependency conflicts** : Supprimer `pubspec.lock` et relancer `flutter pub get`
- **Firebase errors** : Vérifier `google-services.json` et configuration

#### Runtime Errors

- **Permission denied** : Configurer les permissions dans AndroidManifest.xml
- **Firebase not initialized** : Vérifier l'initialisation dans `main.dart`
- **Network errors** : Tester la connectivité et les règles Firestore

### Logs et debugging

```bash
# Logs détaillés
flutter run --verbose

# Logs Android
adb logcat

# Logs Firebase
flutter run --debug
```

## 📞 Support

En cas de problème :

1. Consulter la documentation Flutter : [flutter.dev](https://flutter.dev)
2. Vérifier les issues GitHub du projet
3. Contacter l'équipe de développement

---

**Configuration réussie !** 🎉
Votre environnement SQUAD CI est maintenant prêt pour le développement.
