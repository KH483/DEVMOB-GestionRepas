import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured.');
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQZAlcUkX2BhBRZV_TgDo-vHwUOgRQ8-0',
    appId: '1:95499282467:web:2d6eaff6627ec2be922996',
    messagingSenderId: '95499282467',
    projectId: 'gestionrepas1',
    storageBucket: 'gestionrepas1.firebasestorage.app',
    authDomain: 'gestionrepas1.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQZAlcUkX2BhBRZV_TgDo-vHwUOgRQ8-0',
    appId: '1:95499282467:android:2d6eaff6627ec2be922996',
    messagingSenderId: '95499282467',
    projectId: 'gestionrepas1',
    storageBucket: 'gestionrepas1.firebasestorage.app',
  );
}
