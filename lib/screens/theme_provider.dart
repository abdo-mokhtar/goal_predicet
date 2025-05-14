import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData =>
      _isDarkMode
          ? ThemeData.dark().copyWith(
            primaryColor: Colors.green[700],
            scaffoldBackgroundColor: Color(0xFF1A1A1A),
            cardColor: Color(0xFF2C2C2C),
            textTheme: TextTheme(
              headlineSmall: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
          : ThemeData.light().copyWith(
            primaryColor: Colors.green[700],
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
