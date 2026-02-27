import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Cores Global do Jogo
  static const Color primaryColor = Color(
    0xFF1A237E,
  ); // Azul Escuro (Mistério / Super Prêmio)
  static const Color secondaryColor = Color(
    0xFF00E676,
  ); // Verde Neon (Ache e Ganhe / Sucesso / Radar)
  static const Color accentColor = Color(
    0xFFFFD600,
  ); // Âmbar/Dourado (EnigmaCoins)
  static const Color darkBackground = Color(0xFF121212); // Fundo do modo escuro

  // ==========================================
  // TEMA CLARO (Ideal para jogar de dia na rua)
  // ==========================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.grey.shade50,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
    ),

    // Configuração da AppBar (Barra superior)
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // Estilo global dos botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    // Estilo global dos Cards (onde ficam os enigmas e dicas)
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );

  // ==========================================
  // TEMA ESCURO (O visual "Hacker/Detetive" do jogo)
  // ==========================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E1E1E), // Cinza bem escuro para os cards
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black, // Fundo totalmente preto
      foregroundColor: secondaryColor, // Textos e ícones em verde neon
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor, // Botões em verde neon
        foregroundColor: Colors.black87, // Texto escuro para dar contraste
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2C2C2C), // Cards levemente mais claros que o fundo
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Configuração extra para os modais (BottomSheet) do mapa
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
