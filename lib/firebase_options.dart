// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members, depend_on_referenced_packages
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC909VrFRu0_Lpp6bXgXhcxIGpT8Gpv104',
    appId: '1:437642629359:web:0e7fdc7f31718f64fa8b1a',
    messagingSenderId: '437642629359',
    projectId: 'authenticoproject',
    authDomain: 'authenticoproject.firebaseapp.com',
    storageBucket: 'authenticoproject.appspot.com',
    measurementId: 'G-MB0MVT9ZC5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9DJegxK7HVL2VaQienp8vhQgBPDqV-Hs',
    appId: '1:437642629359:android:89a0f62ae3899e44fa8b1a',
    messagingSenderId: '437642629359',
    projectId: 'authenticoproject',
    storageBucket: 'authenticoproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDK_IUInxpWAf48P3DlJealNXRcymPieyo',
    appId: '1:437642629359:ios:3cf0dfe2d8db1ddffa8b1a',
    messagingSenderId: '437642629359',
    projectId: 'authenticoproject',
    storageBucket: 'authenticoproject.appspot.com',
    iosBundleId: 'com.example.authentico',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDK_IUInxpWAf48P3DlJealNXRcymPieyo',
    appId: '1:437642629359:ios:c6e504c60ec19397fa8b1a',
    messagingSenderId: '437642629359',
    projectId: 'authenticoproject',
    storageBucket: 'authenticoproject.appspot.com',
    iosBundleId: 'com.example.authentico.RunnerTests',
  );
}
