import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    // Mobile platforms are not fully supported yet in this setup, falling back to web config
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCz3-eKysLvCtnp4PD_nOXgVNCw8PqEp8M',
    appId: '1:270255652729:web:4d8f7f76937b21511139a8',
    messagingSenderId: '270255652729',
    projectId: 'le3betna-32671',
    authDomain: 'le3betna-32671.firebaseapp.com',
    storageBucket: 'le3betna-32671.firebasestorage.app',
    databaseURL: 'https://le3betna-32671-default-rtdb.firebaseio.com',
  );
}
