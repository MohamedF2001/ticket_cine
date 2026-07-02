import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/views/seat_select.dart';
import 'package:ticket_cine/services/session_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/widgets/flippable.dart';
import '../../models/user_model.dart';

class Seance extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const Seance({super.key, required this.user, required this.onLogout});

  @override
  State<Seance> createState() => SeanceState();
}

class SeanceState extends State<Seance> {
  final SessionService _sessionService = SessionService();
  List<Session> _sessions = [];
  bool _isLoading = true;

  void refreshData() {
    _loadSessions();
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _sessionService.getAllSeances();
      if (mounted) {
        setState(() => _sessions = response.seances);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des séances : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Cette semaine au cinéma"),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCube(
                color: AppColors.primary,
                size: 40,
              ),
            )
          : _sessions.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune séance disponible',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: FlippableCard(
                          session: session,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SeatSelectionPage(seance: session),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
