// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'screens/main_scaffold.dart'; // asegúrate que este path exista

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCFXlMcZ9woy5XsSN-cVy7E02utV0GkTI4",
        authDomain: "appsflutter-cae39.firebaseapp.com",
        projectId: "appsflutter-cae39",
        // ⚠️ normalmente es appspot.com, revisa en Firebase Console
        storageBucket: "appsflutter-cae39.appspot.com",
        messagingSenderId: "193511686223",
        appId: "1:193511686223:web:d87c5223528359c580ea3a",
      ),
    );
    print('✅ Firebase inicializado correctamente');
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      print('❌ Error al inicializar Firebase: $e');
      rethrow;
    }
  }

  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Digital',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.deepOrangeM3,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useMaterial3Typography: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.deepOrangeM3,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      // Usa tu contenedor con el BottomNavigationBar
      home: const MainScaffold(),
    );
  }
}
