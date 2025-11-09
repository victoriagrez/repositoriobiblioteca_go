import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblioteca_go/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary, // ← color primario desde FlexColorScheme
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.book_ribbon, // ← Google Material Symbol
                size: 96,
                color: cs.onPrimary,
                // Opcional: estilos del símbolo (outlined/filled/weight/grade):
                // fill: 0, weight: 400, grade: 0, opticalSize: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'BibliotecaGo',
                style: GoogleFonts.poppins( // o GoogleFonts.poppins()
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimary,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
