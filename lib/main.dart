import 'package:flutter/foundation.dart'; // ওয়েবের জন্য
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 Firebase ইমপোর্ট
import 'package:firebase_auth/firebase_auth.dart'; // লগইন চেক করার জন্য
import 'package:shared_preferences/shared_preferences.dart'; // অনবোর্ডিং চেক করার জন্য
import 'dart:ui';

import 'core/api_client.dart';
import 'services/tmdb_service.dart';
import 'providers/movie_provider.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart'; // অনবোর্ডিং স্ক্রিন

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 ১. Firebase ইনিশিয়ালাইজেশন (ওয়েব ও মোবাইলের জন্য)
  if (kIsWeb) {
    // ওয়েবের জন্য তোমার কনফিগ বসাতে হবে (যদি আগে বসিয়ে থাকো, সেটা এখানে দাও)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "AIzaSyAhvULeOXXQ_K432dZArDaAHcaukNowM4c", // তোমার কপি করা API Key
        appId: "1:50096706392:web:5ebe68c4ea37b27348cb2d",
        messagingSenderId: "50096706392",
        projectId: "movie-info-app-8bed0",
        storageBucket: "movie-info-app-8bed0.firebasestorage.app",
      ),
    );
  } else {
    // অ্যান্ড্রয়েড/আইফোনের জন্য
    await Firebase.initializeApp();
  }

  // এনভায়রনমেন্ট লোড
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found.");
  }

  // 🔥 ২. অনবোর্ডিং চেক (ইউজার কি প্রথমবার এসেছে?)
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  final apiClient = ApiClient.create();
  final tmdb = TmdbService(apiClient);

  // ৩. অ্যাপ রান করা
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider(tmdb)),
      ],
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Info App',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),

      // 🔥 ৪. রাউটিং লজিক
      // যদি প্রথমবার হয় -> Onboarding
      // যদি লগইন করা থাকে -> Home
      // যদি লগইন না থাকে -> Login
      home: isFirstTime
          ? const OnboardingScreen()
          : (FirebaseAuth.instance.currentUser != null
              ? const HomeScreen()
              : const LoginScreen()),

      routes: {
        '/home': (_) => const HomeScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
