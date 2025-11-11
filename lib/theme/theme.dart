import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color naranjaPrimario = Color(0xFFEB5F28); 
  static const Color azulSecundario = Color(0xFF28A9B8);
  static const Color fondoClaro = Color(0xFFF5F5F0);      
  static const Color naranjaOscuro = Color(0xFFAC3306);   
  static const Color amarilloEstrella = Color(0xFFFFA726); 

  static ThemeData lightTheme = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: naranjaPrimario,
      primaryContainer: naranjaPrimario,
      secondary: azulSecundario,
      secondaryContainer: azulSecundario,
      tertiary: naranjaOscuro,
      tertiaryContainer: naranjaOscuro,
      appBarColor: naranjaPrimario,
      error: Color(0xFFB00020),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 0,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 0,
      blendOnColors: false,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
    ),
    keyColors: const FlexKeyColors(
      useKeyColors: false,
      useSecondary: false,
      useTertiary: false,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    scaffoldBackground: fondoClaro,
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: naranjaPrimario,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      surfaceTintColor: Colors.transparent, 
      scrolledUnderElevation: 0,           
    ),
    colorScheme: const ColorScheme.light(
      primary: naranjaPrimario,
      secondary: azulSecundario,
      surfaceTint: Colors.transparent,
    ),
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: naranjaPrimario,
      primaryContainer: naranjaPrimario,
      secondary: azulSecundario,
      secondaryContainer: azulSecundario,
      tertiary: naranjaOscuro,
      tertiaryContainer: naranjaOscuro,
      appBarColor: naranjaPrimario,
      error: Color(0xFFCF6679),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 0,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 0,
      blendOnColors: false,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
    ),
    keyColors: const FlexKeyColors(
      useKeyColors: false,
      useSecondary: false,
      useTertiary: false,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: naranjaPrimario,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: naranjaPrimario,
      secondary: azulSecundario,
      surfaceTint: Colors.transparent,
    ),
  );
}
