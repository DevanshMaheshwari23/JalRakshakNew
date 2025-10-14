import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCysyqUdP6E4npGedPgPJwlV2eSN1LgR2I",
            authDomain: "jalrakshak-fe186.firebaseapp.com",
            projectId: "jalrakshak-fe186",
            storageBucket: "jalrakshak-fe186.firebasestorage.app",
            messagingSenderId: "57884683015",
            appId:
                "1:57884683015:web:xxxxx", // You'll need web app ID if using web
            measurementId: "G-FW90DZPKRL"));
  } else {
    // Android/iOS - uses values from google-services.json
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCysyqUdP6E4npGedPgPJwlV2eSN1LgR2I",
            appId: "1:57884683015:android:9bc63547e6a49c368373a2",
            messagingSenderId: "57884683015",
            projectId: "jalrakshak-fe186",
            storageBucket: "jalrakshak-fe186.firebasestorage.app"));
  }
}
