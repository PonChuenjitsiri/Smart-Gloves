import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sarnmue/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

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
