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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC9Q0OKO8BwUGkxwK2irrFo17xEp3LnavU',
    appId: '1:74714135632:web:7f9002be29ee5ca716e555',
    messagingSenderId: '74714135632',
    projectId: 'buyer-centric-app-2528e',
    authDomain: 'buyer-centric-app-2528e.firebaseapp.com',
    storageBucket: 'buyer-centric-app-2528e.firebasestorage.app',
    measurementId: 'G-WTJN587F80',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf_bE-zX07DRCEBOE4r-OwtfVQ8E6nCfQ',
    appId: '1:74714135632:android:c79cc2b989736c4e16e555',
    messagingSenderId: '74714135632',
    projectId: 'buyer-centric-app-2528e',
    storageBucket: 'buyer-centric-app-2528e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmqKFKsXNm1YFZUPQVzmpnoqUkWf2kKS8',
    appId: '1:74714135632:ios:c5ac6c173d64c78816e555',
    messagingSenderId: '74714135632',
    projectId: 'buyer-centric-app-2528e',
    storageBucket: 'buyer-centric-app-2528e.firebasestorage.app',
    iosBundleId: 'com.example.buyerCentricAppV2',
  );

}