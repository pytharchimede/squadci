// Firebase configuration generated for SQUAD CI
// File generated automatically - DO NOT EDIT MANUALLY

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnrP3hK9_VNm9SjtQPuIMIQ2atI3HQc0A',
    appId: '1:899584058984:web:0e3ba97e2cc59f534cfddd',
    messagingSenderId: '899584058984',
    projectId: 'squad-ci',
    authDomain: 'squad-ci.firebaseapp.com',
    storageBucket: 'squad-ci.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnrP3hK9_VNm9SjtQPuIMIQ2atI3HQc0A',
    appId: '1:899584058984:android:0e3ba97e2cc59f534cfddd',
    messagingSenderId: '899584058984',
    projectId: 'squad-ci',
    storageBucket: 'squad-ci.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnrP3hK9_VNm9SjtQPuIMIQ2atI3HQc0A',
    appId: '1:899584058984:ios:squad-ci-ios',
    messagingSenderId: '899584058984',
    projectId: 'squad-ci',
    storageBucket: 'squad-ci.firebasestorage.app',
    iosBundleId: 'com.succeslab.squadci',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnrP3hK9_VNm9SjtQPuIMIQ2atI3HQc0A',
    appId: '1:899584058984:macos:squad-ci-macos',
    messagingSenderId: '899584058984',
    projectId: 'squad-ci',
    storageBucket: 'squad-ci.firebasestorage.app',
    iosBundleId: 'com.succeslab.squadci',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBnrP3hK9_VNm9SjtQPuIMIQ2atI3HQc0A',
    appId: '1:899584058984:windows:squad-ci-windows',
    messagingSenderId: '899584058984',
    projectId: 'squad-ci',
    storageBucket: 'squad-ci.firebasestorage.app',
  );
}
