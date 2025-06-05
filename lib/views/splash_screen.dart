import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/views/dashbord.dart';
import 'package:ticket_cine/auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    print("DEBUTTTTTTTTTTTTTTTTT");
    try {
      final authService = AuthService();
      final user =
          await authService.getUser(); // Essayer de récupérer l'utilisateur

      if (!mounted) return;
      print("User: $user");
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => HomeNavigation(
                  user: user,
                ), // Passer l'utilisateur à la HomePage
          ),
        );
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } catch (e, st) {
      if (!mounted) return;
      print("Erreur lors de la récupération de l'utilisateur: $e\n$st");
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5), // Noir très sombre
                Colors.black.withOpacity(0.6), // Noir un peu plus clair
                Colors.black.withOpacity(0.7), // Blanc très léger
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/cinema.png', width: 150),
              const SizedBox(height: 30),
              const Text(
                'MoviePass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const SpinKitPulse(
                duration: Duration(seconds: 5),
                color: Colors.white70,
              )
            ],
          ),
        ),
      ),
    );
  }
}
