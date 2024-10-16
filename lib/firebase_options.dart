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
    apiKey: 'AIzaSyBquGjA3fx_RlGcDupTtNFwUctoFXj-zAY',
    appId: '1:708811505333:web:559654e66388b825f508fc',
    messagingSenderId: '708811505333',
    projectId: 'movemate-bb487',
    authDomain: 'movemate-bb487.firebaseapp.com',
    storageBucket: 'movemate-bb487.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaZy4VTx61msImwqQUiABaHliQhTkXc5g',
    appId: '1:708811505333:android:69e520c4c167bffef508fc',
    messagingSenderId: '708811505333',
    projectId: 'movemate-bb487',
    storageBucket: 'movemate-bb487.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkY04sXx3lx5sNbKnkL48kQC8fkKJdpyk',
    appId: '1:708811505333:ios:30c84bbd802bab73f508fc',
    messagingSenderId: '708811505333',
    projectId: 'movemate-bb487',
    storageBucket: 'movemate-bb487.appspot.com',
    iosBundleId: 'com.example.movemateStaff',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkY04sXx3lx5sNbKnkL48kQC8fkKJdpyk',
    appId: '1:708811505333:ios:30c84bbd802bab73f508fc',
    messagingSenderId: '708811505333',
    projectId: 'movemate-bb487',
    storageBucket: 'movemate-bb487.appspot.com',
    iosBundleId: 'com.example.movemateStaff',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBquGjA3fx_RlGcDupTtNFwUctoFXj-zAY',
    appId: '1:708811505333:web:559654e66388b825f508fc',
    messagingSenderId: '708811505333',
    projectId: 'movemate-bb487',
    authDomain: 'movemate-bb487.firebaseapp.com',
    storageBucket: 'movemate-bb487.appspot.com',
  );

}