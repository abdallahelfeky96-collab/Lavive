import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffe7f6d4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffe7f6d4),
          elevation: 0,
          // iconTheme: IconThemeData(
          //   color: Colors.black87,
          // ),
          // titleTextStyle: TextStyle(
          //   color: Colors.black87,
          //   fontSize: 20,
          //   fontWeight: FontWeight.w600,
          // ),
        ),
      );
}

class DarkTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF3E4533),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3E4533),
          elevation: 0,
          // iconTheme: IconThemeData(
          //   color: Colors.white,
          // ),
          // titleTextStyle: TextStyle(
          //   color: Colors.white,
          //   fontSize: 20,
          //   fontWeight: FontWeight.w600,
          // ),
        ),
      );
}
