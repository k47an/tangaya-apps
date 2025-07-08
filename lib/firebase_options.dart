import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseEnvOptions {
  static String _get(String name) {
    return dotenv.env[name] ?? '';
  }

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

  static final String _projectId = _get('FIREBASE_PROJECT_ID');
  static final String _messagingSenderId = _get('FIREBASE_MESSAGING_SENDER_ID');
  static final String _storageBucket = _get('FIREBASE_STORAGE_BUCKET');

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _get('FIREBASE_WEB_API_KEY'),
        appId: _get('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _get('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: _storageBucket,
        measurementId: _get('FIREBASE_WEB_MEASUREMENT_ID'),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _get('FIREBASE_ANDROID_API_KEY'),
        appId: _get('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _get('FIREBASE_IOS_API_KEY'),
        appId: _get('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _get('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: _get('FIREBASE_IOS_API_KEY'), 
        appId: _get('FIREBASE_IOS_APP_ID'),   
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _get('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: _get('FIREBASE_WINDOWS_API_KEY'),
        appId: _get('FIREBASE_WINDOWS_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _get('FIREBASE_WINDOWS_AUTH_DOMAIN'),
        storageBucket: _storageBucket,
        measurementId: _get('FIREBASE_WINDOWS_MEASUREMENT_ID'),
      );
}