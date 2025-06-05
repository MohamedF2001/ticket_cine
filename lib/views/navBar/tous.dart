import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
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
        // Rediriger vers la page des réservations (à créer)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation vers mes réservations (à faire)')),
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
      backgroundColor: Colors.black.withOpacity(0.4),
      /* appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.5),
        centerTitle: true,
        title: const Text('Movies', style: TextStyle(color: Colors.white)),
      ), */
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.5),
        centerTitle: true,
        title: Text(
          'Bienvenue, ${widget.user.prenom} ${widget.user.nom}',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'profile', child: Text('Profil')),
                  PopupMenuItem(
                    value: 'change_password',
                    child: Text('Changer le mot de passe'),
                  ),
                  PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
                ],
          ),
        ],
      ),

      body: SingleChildScrollView(
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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [HorizontalMovieList(), PopularPage(), TopRatedPage()],
            ),
          ),
        ),
      ),
    );
  }
}
