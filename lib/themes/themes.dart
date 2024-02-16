import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Color.fromARGB(255, 158, 154, 154),
    primary: Color(0xFF3498DB), // Vibrant blue
    secondary: Color.fromARGB(255, 210, 220, 225),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color.fromARGB(255, 20, 20, 20), // Adjusted for visibility
    primary: Color(0xFF3498DB), // Vibrant blue (same as light mode for consistency)
    secondary: Color.fromARGB(255, 97, 93, 93),
  ),
);
