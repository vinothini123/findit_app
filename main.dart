import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login.dart'; // Make sure this file exists in lib/pages/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // These are YOUR specific keys that will stop the blank page
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAehOMVTvXliUpvdNbyrmdolOAKDeU9cAg",
        authDomain: "findit-373c2.firebaseapp.com",
        projectId: "findit-373c2",
        storageBucket: "findit-373c2.firebasestorage.app",
        messagingSenderId: "21606099645",
        appId: "1:21606099645:web:3631a99f9b4d93b76f65d4",
        measurementId: "G-KF1D07K0PK",
      ),
    );
    print("Firebase initialized successfully! ✅");
  } catch (e) {
    print("Firebase Initialization Error: $e ❌");
  }

  runApp(const FindItApp());
}

class FindItApp extends StatelessWidget {
  const FindItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindIt Campus',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
          brightness: Brightness.light,
        ),
      ),
      // Starting point: The Login Page
      home: const LoginPage(),
    );
  }
}