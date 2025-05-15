import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDCQrY8IpigKt5CSCUkHQbq2PtbQXWwWyo",
    authDomain: "testpfe-daa55.firebaseapp.com",
    projectId: "testpfe-daa55",
    storageBucket: "testpfe-daa55.firebasestorage.app",
    messagingSenderId: "593391273273",
    appId: "1:593391273273:web:3e068745008e21826ed4e8",
    // Note: measurementId est optionnel si vous n'utilisez pas Google Analytics
  );
}