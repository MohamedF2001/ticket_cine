import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/views/auth/register_screen.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/views/main/home_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        _numeroController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeNavigationScreen(user: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la connexion. Vérifiez vos identifiants.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
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
                      // Logo Animation
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
                      // Title Animation
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Bon retour !',
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
                          'Connectez-vous pour accéder à vos réservations',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Glassmorphic Form Card
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
                                    'Connexion',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildTextField(
                                    controller: _numeroController,
                                    label: 'Numéro de téléphone',
                                    icon: Icons.phone_android_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) =>
                                        value?.isEmpty ?? true ? 'Entrez votre numéro' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    validator: (value) =>
                                        value?.isEmpty ?? true ? 'Entrez votre mot de passe' : null,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.primaryColor,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: _login,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: const Text(
                                            'Se connecter',
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
                      // Register Link
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte ? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'S\'inscrire',
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
    TextInputType? keyboardType,
    Widget? suffixIcon,
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

  void _showForgotPasswordDialog() {
    final phoneController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Réinitialiser le mot de passe', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre numéro de téléphone et votre nouveau mot de passe.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              final newPassword = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              if (phone.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red),
                );
                return;
              }

              if (newPassword != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red),
                );
                return;
              }

              final success = await _authService.forgotPassword(phone, newPassword);

              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mot de passe réinitialisé avec succès'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Échec de la réinitialisation du mot de passe'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
