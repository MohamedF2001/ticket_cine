import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/views/main/seat_selection_screen.dart';

import '../../theme/app_theme.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final SessionService _sessionService = SessionService();
  late Future<SessionResponse> _sessionsFuture;

  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Aujourd\'hui', 'Ce week-end', 'VIP', 'Standard'];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    setState(() {
      _sessionsFuture = _sessionService.getAllSeances();
    });
  }

  List<Session> _filterSessions(List<Session> sessions) {
    if (_selectedFilter == 'Tous') return sessions;

    final now = DateTime.now();

    if (_selectedFilter == 'Aujourd\'hui') {
      return sessions.where((s) =>
      s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day
      ).toList();
    }

    if (_selectedFilter == 'Ce week-end') {
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      return sessions.where((s) =>
      s.date.isAfter(now) && s.date.isBefore(endOfWeek)
      ).toList();
    }

    if (_selectedFilter == 'VIP') {
      return sessions.where((s) =>
          s.typeSeance.toLowerCase().contains('vip')
      ).toList();
    }

    if (_selectedFilter == 'Standard') {
      return sessions.where((s) =>
      s.typeSeance.toLowerCase().contains('standard') ||
          s.typeSeance.toLowerCase().contains('normal')
      ).toList();
    }

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Séances',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez votre séance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                      )
                    ),
                  ],
                ),
              ),

              // Filtres
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                  ),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppTheme.surfaceColor,
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Liste des séances
              Expanded(
                child: FutureBuilder<SessionResponse>(
                  future: _sessionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadSessions,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.seances.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.movie_outlined,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune séance disponible',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.15
                              )
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredSessions = _filterSessions(snapshot.data!.seances);

                    if (filteredSessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_list_off,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune séance pour ce filtre',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: 0.15
                              )
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: () async {
                        _loadSessions();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = filteredSessions[index];

                          return _SessionCard(session: session);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeatSelectionScreen(seance: session),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Affiche du film
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${session.imgFilm}',
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 120,
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.movie,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.film,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        text: session.formattedDate,
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.access_time,
                        text: session.formattedTime,
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.meeting_room,
                        text: '${session.salle}',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              session.typeSeance,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${session.prix}F CFA',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 0.25
          )
        ),
      ],
    );
  }
}