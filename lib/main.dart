import 'package:flutter/material.dart';
import 'package:ticket_cine/views/splash_screen.dart';
import 'package:logger/logger.dart';
import 'package:ticket_cine/views/splash_screen_new.dart';

Logger log = Logger();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Ciné',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white, // Couleur du curseur
          selectionColor: Colors.white.withOpacity(0.3), // Couleur de sélection
          selectionHandleColor: Colors.white, // Poignée de sélection
        ),
      ),
      home:
          //SeatSelectionPage(),
          //const SplashScreen(),
      const SplashScreenNew(),
      debugShowCheckedModeBanner: false,
    );
  }
}
