import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intario_ai/app.dart';
import 'package:intario_ai/firebase_options.dart';

void main() async {
  // 1. Ensure bindings are initialized for native splash preservation
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Preserve native splash immediately to prevent early removal
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Set immersive system UI style BEFORE any frames are drawn
  // Since the initial background is now WHITE, we use DARK icons.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 4. Lock orientation early
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // 5. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // 6. Launch the App
  runApp(
    const ProviderScope(
      child: IntarioApp(),
    ),
  );
}
