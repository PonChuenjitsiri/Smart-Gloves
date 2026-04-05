import 'package:flutter/material.dart';
import 'package:sarnmue/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2260FF),
        fontFamily: 'Taviraj',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Taviraj'),
          bodyMedium: TextStyle(fontFamily: 'Taviraj'),
          displayLarge:
              TextStyle(fontFamily: 'Taviraj', fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(fontFamily: 'Taviraj', fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
