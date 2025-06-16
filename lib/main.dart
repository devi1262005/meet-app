import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'page/Splash.dart'; // Ensure this path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async operations in main()

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");

    // Initialize WebRTC
    await WebRTC.initialize(options: {
      'enableVideo': true,
      'enableAudio': true,
      'enableDataChannel': true,
    });
    print("WebRTC initialized successfully!");

  } catch (e) {
    print("Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(), // Ensure this page exists
    );
  }
}
