import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'page/Splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyALJQG8b9mGUU-2aOSSXYred03q2550R0Q",
      appId: "1:637344477928:android:90d7e3d782d0c7eaa24f5d",
      messagingSenderId: "637344477928",
      projectId: "meeting-ds",
    ),
  );
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(), 
    );
  }
}
