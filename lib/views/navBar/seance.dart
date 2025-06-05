import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/views/seat_select.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/views/splash_screen.dart';
import 'package:ticket_cine/widgets/flippable.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../auth/login_page.dart';

class Seance extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const Seance({super.key, required this.user, required this.onLogout});

  @override
  State<Seance> createState() => SeanceState();
}

class SeanceState extends State<Seance> {
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();
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
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.5),
        centerTitle: true,
        title: Flexible(
          child: Text(
            maxLines: 2,
            "Cette semaine au cinéma",
            softWrap: true,
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'profile', child: Text('Profil')),
                  PopupMenuItem(
                    value: 'reservations',
                    child: Text('Mes réservations'),
                  ),
                  PopupMenuItem(
                    value: 'change_password',
                    child: Text('Changer le mot de passe'),
                  ),
                  PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
                ],
          ),
        ],
      ),

      body: _isLoading
          ? Center(
        child: SpinKitPulse(
          duration: const Duration(seconds: 3),
          color: Colors.white70,
        ),
      )
          : _sessions.isEmpty
          ? const Center(child: Text('Aucune séance disponible', style: TextStyle(color: Colors.white)))
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: _sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final session = _sessions[index];
            return FlippableCard(
              session: session,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeatSelectionPage(seance: session),
                  ),
                );
              },
            );
          },
        ),
      ),


      /*body:
          _isLoading
              ? Center(child: SpinKitPulse(
            duration: Duration(seconds: 3),
            color: Colors.white70,
          )
          )
              : _sessions.isEmpty
              ? const Center(child: Text('Aucune séance disponible'))
              : Container(
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
                child: PageView.builder(
                  itemCount: _sessions.length,
                  controller: PageController(
                    viewportFraction: 0.9,
                  ), // Réduire légèrement
                  padEnds: true, // Ajoute de l'espace aux extrémités
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: FlippableCard(
                        session: session,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SeatSelectionPage(seance: session)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),*/
    );
  }
} 

/* import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/views/seat_select.dart';
import 'package:ticket_cine/widgets/flippable.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../auth/login_page.dart';

class Seance extends StatefulWidget {
  final UserModel user;

  const Seance({super.key, required this.user});

  @override
  State<Seance> createState() => _SeanceState();
}

class _SeanceState extends State<Seance> {
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();
  List<Session> _sessions = [];
  bool _isLoading = true;

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
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
        );
        break;
      case 'reservations':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation vers mes réservations (à faire)')),
        );
        break;
      case 'change_password':
        _showChangePasswordDialog();
        break;
      case 'logout':
        await _authService.logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
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
              TextButton(
                onPressed: () async {
                  // Implémente ici la logique de changement de mot de passe
                  Navigator.pop(context);
                },
                child: const Text('Valider'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.5),
        centerTitle: true,
        title: Text(
          "Cette semaine au cinéma",
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
                    value: 'reservations',
                    child: Text('Mes réservations'),
                  ),
                  PopupMenuItem(
                    value: 'change_password',
                    child: Text('Changer le mot de passe'),
                  ),
                  PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _sessions.isEmpty
              ? const Center(
                child: Text(
                  'Aucune séance disponible',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: ListView.builder(
                  //padding: const EdgeInsets.all(5),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeatSelectionPage(seance: session),
                          ),
                        );
                      },
                      child: FlippableCard(
                        session: session,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SeatSelectionPage(seance: session),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
 */