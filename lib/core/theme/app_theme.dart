import 'package:flutter/material.dart';

/// Palette de couleurs étendue pour le thème sombre et clair
class AppColors {
  // Couleurs principales LOGEST
  static const Color primary = Color(0xFF1976D2);      // Bleu professionnel
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryAccent = Color(0xFF64B5F6);
  
  // Couleurs de statut
  static const Color success = Color(0xFF4CAF50);       // Vert - Mission terminée/facturée
  static const Color warning = Color(0xFFFF9800);       // Orange - En cours/retard
  static const Color error = Color(0xFFF44336);         // Rouge - Problème
  static const Color info = Color(0xFF2196F3);          // Bleu - En route/arrivé
  
  // Couleurs de type de mission
  static const Color billed = Color(0xFF4CAF50);        // Vert - Facturée
  static const Color interContract = Color(0xFF9E9E9E); // Gris - Inter-contrat
  static const Color training = Color(0xFFFFEB3B);      // Jaune - Formation
  static const Color leave = Color(0xFF2196F3);         // Bleu - Congé
  
  // Couleurs neutres LIGHT
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  
  // Couleurs neutres DARK
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF2C2C2C);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);
  
  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Ombres
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Thème Light moderne avec Material 3
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.primaryAccent,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      error: AppColors.error,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 24),
      toolbarHeight: 60,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackgroundLight,
      margin: EdgeInsets.zero,
    ),
    
    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppColors.primary, width: 2),
        foregroundColor: AppColors.primary,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: AppColors.primary,
      ),
    ),
    
    // Champs de formulaire
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 15),
      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
      prefixIconColor: AppColors.textSecondaryLight,
      suffixIconColor: AppColors.textSecondaryLight,
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    
    // Navigation Rail (pour tablette/web)
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      labelType: NavigationRailLabelType.all,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimaryLight,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: AppColors.surfaceLight,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondaryLight,
      ),
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      backgroundColor: AppColors.dividerLight,
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: 1,
    ),
    
    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 24,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryLight),
      bodyMedium: TextStyle(fontSize: 15, color: AppColors.textSecondaryLight),
      bodySmall: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
    ),
  );
  
  /// Thème Dark moderne
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryAccent,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      toolbarHeight: 60,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackgroundDark,
      margin: EdgeInsets.zero,
    ),
    
    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.backgroundDark,
        shadowColor: AppColors.primaryAccent.withOpacity(0.3),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppColors.primaryAccent, width: 2),
        foregroundColor: AppColors.primaryAccent,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: AppColors.primaryAccent,
      ),
    ),
    
    // Champs de formulaire
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dividerDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dividerDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryAccent, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 15),
      hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
      prefixIconColor: AppColors.textSecondaryDark,
      suffixIconColor: AppColors.textSecondaryDark,
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryAccent,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    
    // Navigation Rail
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      labelType: NavigationRailLabelType.all,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryAccent,
      foregroundColor: AppColors.backgroundDark,
      elevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondaryDark,
      ),
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      backgroundColor: AppColors.dividerDark,
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),
    
    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 24,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryDark),
      bodyMedium: TextStyle(fontSize: 15, color: AppColors.textSecondaryDark),
      bodySmall: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
    ),
  );
}
