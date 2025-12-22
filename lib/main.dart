import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../screens/splash.dart';

//lib/utils/constants.dart
//lib/models/case.dart
//lib/services/auth.dart
//lib/services/firestore.dart
//lib/services/api.dart
//lib/widgets/input_field.dart
//lib/widgets/primary_button.dart
//lib/widgets/risk_card.dart
//lib/screens/splash.dart
//lib/screens/login.dart
//lib/screens/register.dart
//lib/screens/verify_email.dart
//lib/screens/home.dart
//lib/screens/case_form.dart
//lib/screens/case_detail.dart
//lib/screens/medical_report.dart
//utils/pdf_generator.dart
//lib/Utils/pdf_export.dart
//lib/Utils/pdf_export_web.dart
//lib/Utils/pdf_export_io.dart
//android/key.properties

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مرة واحدة فقط
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA6irWoFNRbw47kXSFOevhqwjeVh__tk9w",
        authDomain: "fir-config-a32ad.firebaseapp.com",
        projectId: "fir-config-a32ad",
        storageBucket: "fir-config-a32ad.firebasestorage.app",
        messagingSenderId: "608822184738",
        appId: "1:608822184738:web:8a5ee8927125cb8b61737b",
      ),
    );
  } catch (e) {
    print('Firebase already initialized: $e');
  }


  runApp(
    Provider<AuthService>(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heart Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const SplashScreen(),  // ← الرجوع للـ SplashScreen الحقيقى
    );
  }
}