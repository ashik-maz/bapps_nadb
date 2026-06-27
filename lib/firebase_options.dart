import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'mock-web-api-key',
        appId: 'mock-web-app-id',
        messagingSenderId: 'mock-web-sender-id',
        projectId: 'mock-web-project-id',
        authDomain: 'mock-web-auth-domain',
        storageBucket: 'mock-web-storage-bucket',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'mock-android-api-key',
          appId: 'mock-android-app-id',
          messagingSenderId: 'mock-android-sender-id',
          projectId: 'mock-android-project-id',
          storageBucket: 'mock-android-storage-bucket',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'mock-ios-api-key',
          appId: 'mock-ios-app-id',
          messagingSenderId: 'mock-ios-sender-id',
          projectId: 'mock-ios-project-id',
          storageBucket: 'mock-ios-storage-bucket',
          iosBundleId: 'com.srpallab.quizMaster',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }
}
