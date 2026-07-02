import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/session_service.dart';
import 'package:ticket_cine/widgets/flippable.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../auth/login_page.dart';
import '../seat_select.dart';

class Seat extends StatefulWidget {
  final UserModel user;

  const Seat({super.key, required this.user, required Session seance});

  @override
  State<Seat> createState() => _SeatState();
}

class _SeatState extends State<Seat> {
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
              ? Center(child: SpinKitPulse(
            duration: Duration(seconds: 3),
            color: Colors.white70,
          ))
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
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return FlippableCard(
                      session: session,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeatSelectionPage(seance: session),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
    );
  }
}
