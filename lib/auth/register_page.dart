import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ticket_cine/auth/login_page.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/views/dashbord.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final numeroController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = AuthService();
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    numeroController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await authService.register(
        nomController.text.trim(),
        prenomController.text.trim(),
        numeroController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeNavigation(user: user),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de l'inscription"),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image with opacity
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cinema.png'),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
          ),
          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundColor.withOpacity(0.6),
                  AppTheme.backgroundColor.withOpacity(0.9),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/cinema.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          "Créer un compte",
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          "Rejoignez CinéBook et réservez vos séances",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: AppTheme.glassDecoration(radius: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Inscription",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildTextField(
                                    controller: nomController,
                                    label: "Nom",
                                    icon: Icons.person_outline,
                                    validator: (v) => v?.isEmpty ?? true ? "Entrez votre nom" : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: prenomController,
                                    label: "Prénom",
                                    icon: Icons.person_outline,
                                    validator: (v) => v?.isEmpty ?? true ? "Entrez votre prénom" : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: numeroController,
                                    label: "Numéro de téléphone",
                                    icon: Icons.phone_android_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) => v?.isEmpty ?? true ? "Entrez votre numéro" : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: passwordController,
                                    label: "Mot de passe",
                                    icon: Icons.lock_outline,
                                    obscureText: _obscureText,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureText = !_obscureText);
                                      },
                                    ),
                                    validator: (v) {
                                      if (v?.isEmpty ?? true) return "Entrez un mot de passe";
                                      if (v!.length < 6) return "Minimum 6 caractères";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: confirmPasswordController,
                                    label: "Confirmer le mot de passe",
                                    icon: Icons.lock_outline,
                                    obscureText: _obscureConfirmText,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureConfirmText = !_obscureConfirmText);
                                      },
                                    ),
                                    validator: (v) => v?.isEmpty ?? true ? "Confirmez votre mot de passe" : null,
                                  ),
                                  const SizedBox(height: 32),
                                  _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.primaryColor,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: const Text(
                                            "S'inscrire",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Déjà un compte ? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                "Se connecter",
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
