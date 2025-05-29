import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBAAXKee5CksdfGBees55OcRXnC1IJko64",
    authDomain: "parkeringsapp-2e0f4.firebaseapp.com",
    projectId: "parkeringsapp-2e0f4",
    storageBucket: "parkeringsapp-2e0f4.firebasestorage.app",
    messagingSenderId: "387548496404",
    appId: "1:387548496404:web:892bf1d61e55b16692dd01",
    measurementId: "G-KQ1D5JVZ8Z",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YOUR_ANDROID_API_KEY",
    projectId: "parkeringsapp-2e0f4",
    messagingSenderId: "387548496404",
    appId: "1:387548496404:android:132c5e98958fb86f92dd01",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    projectId: "parkeringsapp-2e0f4",
    messagingSenderId: "387548496404",
    appId: "1:387548496404:ios:baa4bb1420b450fe92dd01",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "YOUR_MACOS_API_KEY",
    projectId: "parkeringsapp-2e0f4",
    messagingSenderId: "387548496404",
    appId: "1:387548496404:ios:baa4bb1420b450fe92dd01",
  );
}