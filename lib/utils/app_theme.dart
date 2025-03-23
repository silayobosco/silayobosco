import '../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      bodyMedium: appTextStyle(), // Use appTextStyle for body text
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: appTextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(8.0)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: errorColor), borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: appButtonStyle(),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: secondaryColor,
    scaffoldBackgroundColor: Colors.grey[900]!,
    textTheme: TextTheme(
      bodyMedium: appTextStyle(color: Colors.white), // Use appTextStyle for body text
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850]!,
      titleTextStyle: appTextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secondaryColor), borderRadius: BorderRadius.circular(8.0)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: errorColor), borderRadius: BorderRadius.circular(8.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: appButtonStyle(backgroundColor: secondaryColor),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.toString());
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeModeString);
      notifyListeners();
    }
  }
}