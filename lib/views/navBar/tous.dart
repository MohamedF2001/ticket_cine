import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/views/splash_screen.dart';
import 'package:ticket_cine/widgets/horizontale.dart';
import 'package:ticket_cine/widgets/popular.dart';
import 'package:ticket_cine/widgets/top_rated.dart';

class Tous extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const Tous({super.key, required this.user, required this.onLogout});
  @override
  State<Tous> createState() => TousState();
}

class TousState extends State<Tous> {
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();

  Future<void> _handleLogout() async {
    try {
      await AuthService().logout();
      widget.onLogout(); // Redirection propre
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de déconnexion : $e')),
      );
    }
  }

  List<Session> _sessions = [];
  bool _isLoading = true;

  // Permet d'appeler fetchSeances() depuis l'extérieur
  void refreshData() {
    _loadSessions();
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _sessionService.getAllSeances();
      setState(() => _sessions = response.seances);
      //setState(() => _sessions = [response.seance]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des séances : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'profile':
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Profil utilisateur'),
                content: Text(
                  'Nom : ${widget.user.nom}\n'
                  'Prénom : ${widget.user.prenom}\n'
                  'Numéro : ${widget.user.numero}',
                ),
              ),
        );
        break;

      case 'reservations':
        // Navigation vers l'onglet tickets (index 2 dans HomeNavigation)
        // Note: Dans dashbord.dart, l'index 2 est LeTicket
        // Comme nous sommes dans une PersistentTabView, nous pouvons essayer de changer l'index du controller
        // Mais ici nous n'avons pas accès directement au controller de HomeNavigation.
        // On va utiliser le feedback utilisateur pour l'instant ou implémenter une solution via Provider/Callback si nécessaire.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez utiliser l\'onglet "Tickets" en bas')),
        );
        break;

      case 'change_password':
        _showChangePasswordDialog();
        break;

      /*case 'logout':
        await _authService.logout();
        // Dans votre page avec bottom bar

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false,
        );
        break;*/
      case 'logout':
        try {
          await AuthService().logout();
          widget.onLogout(); // Redirection propre
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
          );
        }
        break;

    }
  }

  void _showChangePasswordDialog() {
    final _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Changer le mot de passe'),
            content: TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(onPressed: () async {}, child: const Text('Valider')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.2),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${widget.user.prenom} ${widget.user.nom}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onSelected: _onMenuSelected,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Profil'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Sécurité'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: AppTheme.primaryColor),
                            SizedBox(width: 10),
                            Text('Déconnexion', style: TextStyle(color: AppTheme.primaryColor)),
                          ],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: HorizontalMovieList(),
              ),
              const SizedBox(height: 10),
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: PopularPage(),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: TopRatedPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
