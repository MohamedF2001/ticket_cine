import 'package:flutter/material.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/views/splash_screen.dart';
import 'package:logger/logger.dart';

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
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
