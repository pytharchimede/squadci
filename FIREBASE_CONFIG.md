# Configuration Firebase pour SQUAD CI

## 🔥 Configuration Firebase requise

Pour que l'application fonctionne correctement, vous devez configurer Firebase :

### 1. Créer un projet Firebase

- Aller sur [Firebase Console](https://console.firebase.google.com)
- Créer un nouveau projet "squad-ci-app"
- Activer Google Analytics (optionnel)

### 2. Ajouter l'application Android

- Dans Firebase Console, cliquer sur "Ajouter une app"
- Sélectionner Android
- Package name : `com.squadci.app`
- App nickname : `SQUAD CI`
- Télécharger le fichier `google-services.json`

### 3. Installer le fichier de configuration

- Copier `google-services.json` dans le dossier `android/app/`
- Le fichier doit être exactement à : `android/app/google-services.json`

### 4. Configurer les services Firebase

#### Authentication

```
1. Aller dans Authentication > Sign-in method
2. Activer "Anonymous"
3. Activer "Email/Password"
4. Sauvegarder les modifications
```

#### Firestore Database

```
1. Aller dans Firestore Database
2. Créer une base de données
3. Commencer en mode test (règles ouvertes)
4. Choisir la région : europe-west3 (Frankfurt)
```

#### Storage

```
1. Aller dans Storage
2. Démarrer
3. Commencer en mode test
4. Choisir la région : europe-west3 (Frankfurt)
```

### 5. Règles de sécurité (développement)

#### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### Storage Rules

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

### 6. Variables d'environnement

Créer un fichier `.env` (optionnel) :

```env
FIREBASE_PROJECT_ID=squad-ci-app
FIREBASE_API_KEY=votre_api_key
FIREBASE_APP_ID=votre_app_id
```

### 7. Vérification

Une fois configuré, vérifiez que :

- ✅ Le fichier `google-services.json` est présent
- ✅ Authentication est activée
- ✅ Firestore est créée
- ✅ Storage est activé
- ✅ Les règles sont configurées

### 8. Test de connection

Lancez l'application pour vérifier la connexion Firebase :

```bash
flutter run -d chrome
```

L'application devrait démarrer sans erreurs Firebase.

---

⚠️ **Important** : Ne jamais commiter le fichier `google-services.json` dans le repository public. Utilisez `.gitignore` pour l'exclure.

🔒 **Sécurité** : En production, modifier les règles Firebase pour sécuriser l'accès aux données.
