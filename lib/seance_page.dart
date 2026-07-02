/* import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/views/seat_select.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:ticket_cine/services/session_service.dart';
import 'package:ticket_cine/auth/login_page.dart';
import 'create_reservation_page.dart';

class SessionsPage extends StatefulWidget {
  final UserModel user;
  SessionsPage({required this.user});
  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final SessionService _sessionService = SessionService();
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
      setState(
        () => _sessions = response.seances,
      ); // Accédez à la propriété seances
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load sessions: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await _sessionService.deleteSeance(sessionId);
      _loadSessions(); // Recharger la liste après suppression
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Session deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete session: $e')));
    }
  }

  void _confirmDelete(String sessionId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this session?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSession(sessionId);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Sessions'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadSessions),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              // Déconnexion
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _sessions.isEmpty
              ? Center(child: Text('No sessions available'))
              : ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                              //CreateReservationPage(seance: session),
                              SeatSelectionPage(seance: session),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        //leading: Icon(Icons.movie),
                        leading: Image.network(
                          //movie.posterPath,
                          'https://image.tmdb.org/t/p/w500${session.imgFilm}',
                          height: 90,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 140,
                                width: 140,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                        title: Text(session.film),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${session.formattedTime.toString()}'),
                            Text('Type: ${session.typeSeance.toUpperCase()}'),
                            Text('Room: ${session.salle}'),
                            Text('Seats: ${session.placesDisponibles}'),
                            Text('Price: ${session.prix} €'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
 */
