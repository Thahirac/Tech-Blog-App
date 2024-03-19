import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    // ignore: missing_enum_constant_in_switch
     if (defaultTargetPlatform case TargetPlatform.android) {
       return android;
     }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAxGISCZDQBVcNIZ5fbUPHnRFCOQou6bI',
    appId: '1:2607735072:android:1b5b8008b97e04b6b0f745',
    messagingSenderId: '406099696497',
    projectId: 'blogapp-9c897',
    databaseURL: 'gs://blogapp-9c897.appspot.com',
    storageBucket: 'blogapp-9c897.appspot.com',
  );
}