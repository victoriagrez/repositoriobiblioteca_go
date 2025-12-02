import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:biblioteca_go/theme/theme.dart';
import 'package:biblioteca_go/screens/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hola profe, Hice una version con Inicialización de Firebase sin opciones manuales, 
  //ya que tuve problemas con la aplicacion que se me crasheaba con el login
  // de google y no me dejaba ver bien la app por que no pasaba de el icono de el launcher
  //, mi solucion fue quitar el inicio manual, en todo caso si fue eimplementado durante el proyecto y le dejo a continuacion los id.
  

    // inicialización manual con Firebase usada antes:
  /*
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSy...",
        authDomain: "bibliotecadigital-caae0.firebaseapp.com",
        projectId: "bibliotecadigital-caae0",
        storageBucket: "bibliotecadigital-caae0.appspot.com",
        messagingSenderId: "684151998082",
        appId: "1:684151998082:android:...",
      ),
    );
  }
  */

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BibliotecaGo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}
