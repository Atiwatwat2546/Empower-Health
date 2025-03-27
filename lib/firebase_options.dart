// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB1cGt4-DGvJN_eec6LN8HCdyjWyjRqOMA',
    appId: '1:423460179901:web:4391388fb873f5b68dccd4',
    messagingSenderId: '423460179901',
    projectId: 'agile-b3df1',
    authDomain: 'agile-b3df1.firebaseapp.com',
    storageBucket: 'agile-b3df1.firebasestorage.app',
    measurementId: 'G-YRDT29BX7L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChqpEbFQhJkjbUdXg-6C5XrjWiA5m74E4',
    appId: '1:423460179901:android:0730d73b50f9fcf68dccd4',
    messagingSenderId: '423460179901',
    projectId: 'agile-b3df1',
    storageBucket: 'agile-b3df1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC6AWE8_r7imKzuizLg17kxr9hux0wrff4',
    appId: '1:423460179901:ios:cc4a727f0814c6668dccd4',
    messagingSenderId: '423460179901',
    projectId: 'agile-b3df1',
    storageBucket: 'agile-b3df1.firebasestorage.app',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC6AWE8_r7imKzuizLg17kxr9hux0wrff4',
    appId: '1:423460179901:ios:cc4a727f0814c6668dccd4',
    messagingSenderId: '423460179901',
    projectId: 'agile-b3df1',
    storageBucket: 'agile-b3df1.firebasestorage.app',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB1cGt4-DGvJN_eec6LN8HCdyjWyjRqOMA',
    appId: '1:423460179901:web:29faad573c8fcdb28dccd4',
    messagingSenderId: '423460179901',
    projectId: 'agile-b3df1',
    authDomain: 'agile-b3df1.firebaseapp.com',
    storageBucket: 'agile-b3df1.firebasestorage.app',
    measurementId: 'G-TXWHJDSRVC',
  );
}
