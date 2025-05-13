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
    apiKey: 'AIzaSyAWdppvgNXVaCahr0mvNfd09lesSFnsKXo',
    appId: '1:209624047180:web:0b72b232532b1fea851ee9',
    messagingSenderId: '209624047180',
    projectId: 'palala-app-b1873',
    authDomain: 'palala-app-b1873.firebaseapp.com',
    storageBucket: 'palala-app-b1873.appspot.com',
    measurementId: 'G-EP1Y99JGLJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7i-Z9okQEdm9P0jgEfA3whvubusUE26w',
    appId: '1:209624047180:android:38ef5662148e6e27851ee9',
    messagingSenderId: '209624047180',
    projectId: 'palala-app-b1873',
    storageBucket: 'palala-app-b1873.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCj7H5oa9PTxEYaA-_yrWonKbqA53YFfbg',
    appId: '1:209624047180:ios:ecc947aaa5680713851ee9',
    messagingSenderId: '209624047180',
    projectId: 'palala-app-b1873',
    storageBucket: 'palala-app-b1873.appspot.com',
    iosBundleId: 'com.example.tangayaApps',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCj7H5oa9PTxEYaA-_yrWonKbqA53YFfbg',
    appId: '1:209624047180:ios:ecc947aaa5680713851ee9',
    messagingSenderId: '209624047180',
    projectId: 'palala-app-b1873',
    storageBucket: 'palala-app-b1873.appspot.com',
    iosBundleId: 'com.example.tangayaApps',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAWdppvgNXVaCahr0mvNfd09lesSFnsKXo',
    appId: '1:209624047180:web:dbe85e05dc4ce721851ee9',
    messagingSenderId: '209624047180',
    projectId: 'palala-app-b1873',
    authDomain: 'palala-app-b1873.firebaseapp.com',
    storageBucket: 'palala-app-b1873.appspot.com',
    measurementId: 'G-JR32TJZ2DV',
  );
}
