import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// !! WARNING: Storing API keys directly in code is insecure and not recommended for production.
// !! Use environment variables or flutter_secure_storage for production apps.
// !! For development purposes ONLY:
const String geminiApiKey =
    "AIzaSyB4UZMEHMk66Ro8_WqvH46WbWq1bb7RmgU"; // PASTE YOUR KEY HERE
const String groqApiKey =
    "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";
//"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"; // PASTE YOUR KEY HERE

// Colors & Theme (Customize these!)
const Color primaryColor = Colors.deepPurple;
const Color accentColor = Colors.amber;
const Color backgroundColor = Colors.white;
const Color chatBackgroundColor = Color(0xFFF0F0F0);
const Color userBubbleColor = Colors.deepPurpleAccent;
const Color aiBubbleColor = Colors.white;
const Color textColor = Colors.black87;
const Color bubbleTextColor = Colors.white;

ThemeData buildTheme() {
  return ThemeData(
    primarySwatch: Colors.deepPurple,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(), // Use a nice font
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    ),
  );
}
