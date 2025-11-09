/*
import 'package:flutter/material.dart';
import 'package:ticket_cine/models/movie_details.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/views/main/seat_selection_screen.dart';

import '../../theme/app_theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  final SessionService _sessionService = SessionService();

  late Future<MovieDetails> _movieDetailsFuture;
  late Future<SessionResponse> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _movieService.fetchMovieDetails(widget.movieId);
    _sessionsFuture = _sessionService.getSeancesByFilm(widget.movieId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieDetails>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final movie = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // AppBar avec image de fond
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: AppTheme.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropPath != null
                            ? 'https://image.tmdb.org/t/p/w1280${movie.backdropPath}'
                            : movie.backdropPath!,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.backgroundColor,
                            ],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et note
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.accentColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (movie.runtime != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${movie.runtime} min',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          const SizedBox(width: 16),
                          if (movie.releaseDate != null)
                            Text(
                              movie.releaseDate!.substring(0, 4),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Genres
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres
                            .map(
                              (genre) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.textSecondary.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              genre.name,
                              //style: Theme.of(context).textTheme.bodySmall,
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      // Synopsis
                      Text(
                        'Synopsis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 32),

                      // Séances disponibles
                      Text(
                        'Séances disponibles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      FutureBuilder<SessionResponse>(
                        future: _sessionsFuture,
                        builder: (context, sessionSnapshot) {
                          if (sessionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          }

                          if (sessionSnapshot.hasError ||
                              !sessionSnapshot.hasData ||
                              sessionSnapshot.data!.seances.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(AppTheme.paddingLarge),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Aucune séance disponible pour ce film',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }

                          final sessions = sessionSnapshot.data!.seances;

                          return Column(
                            children: sessions.map((session) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.cardGradient,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.textSecondary.withOpacity(0.2),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SeatSelectionScreen(
                                            seance: session,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppTheme.paddingMedium,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(
                                                AppTheme.radiusSmall,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.event_seat,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  session.formattedDate,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      session.formattedTime,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      'Salle ${session.salle}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${session.prix}€',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                  color: AppTheme.accentColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${session.placesDisponibles} places',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}*/


/*import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ticket_cine/models/movie_details.dart';
import 'package:ticket_cine/models/movie_credit.dart';
import 'package:ticket_cine/models/movie_video.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/views/main/seat_selection_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../theme/app_theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final SessionService _sessionService = SessionService();

  late Future<MovieDetails> _movieDetailsFuture;
  late Future<MovieCredits> _movieCreditsFuture;
  late Future<SessionResponse> _sessionsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _movieService.fetchMovieDetails(widget.movieId);
    _movieCreditsFuture = _movieService.fetchMovieCredits(widget.movieId);
    _sessionsFuture =
        _sessionService.getSeancesByFilm(widget.movieId.toString());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showTrailerDialog() async {
    try {
      final videos = await _movieService.fetchMovieVideos(widget.movieId);
      final youtubeVideos =
      videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune bande-annonce disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
        orElse: () => youtubeVideos.firstWhere(
              (v) => v.type == 'Trailer',
          orElse: () => youtubeVideos.first,
        ),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: trailer.key,
                  flags: const YoutubePlayerFlags(
                    autoPlay: true,
                    mute: false,
                  ),
                ),
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppTheme.accentColor,
                progressColors: const ProgressBarColors(
                  playedColor: AppTheme.accentColor,
                  handleColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FutureBuilder(
        future: Future.wait([_movieDetailsFuture, _movieCreditsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
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
                    'Erreur: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final movie = snapshot.data![0] as MovieDetails;
          final credits = snapshot.data![1] as MovieCredits;

          return CustomScrollView(
            slivers: [
              // AppBar avec image de fond
              SliverAppBar(
                expandedHeight: 500,
                pinned: true,
                backgroundColor: AppTheme.backgroundColor,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropPath != null
                            ? 'https://image.tmdb.org/t/p/w1280${movie.backdropPath}'
                            : 'https://via.placeholder.com/1280x720?text=No+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              AppTheme.backgroundColor,
                            ],
                            stops: [0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Informations en bas
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                movie.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Genres
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie.genres.take(3).map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      genre.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              // Bouton bande-annonce
                              ElevatedButton.icon(
                                onPressed: _showTrailerDialog,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Bande-annonce'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note et informations
                        _buildMovieStats(movie),
                        const SizedBox(height: 24),

                        // Synopsis
                        _buildSection(
                          title: 'Synopsis',
                          child: Text(
                            movie.overview.isNotEmpty
                                ? movie.overview
                                : 'Aucun synopsis disponible',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Détails du film
                        _buildSection(
                          title: 'Détails',
                          child: _buildDetailsGrid(movie),
                        ),
                        const SizedBox(height: 24),

                        // Casting
                        if (credits.cast.isNotEmpty) ...[
                          _buildSection(
                            title: 'Casting principal',
                            child: _buildCastList(credits.cast.take(10).toList()),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Séances disponibles
                        _buildSection(
                          title: 'Séances disponibles',
                          child: _buildSessionsList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMovieStats(MovieDetails movie) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.star,
                value: movie.voteAverage.toStringAsFixed(1),
                label: '${movie.voteCount} votes',
                color: AppTheme.accentColor,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.access_time,
                value: '${movie.runtime ?? 0}',
                label: 'minutes',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                value: movie.releaseDate?.substring(0, 4) ?? 'N/A',
                label: 'Sortie',
              ),
            ],
          ),
          const SizedBox(height: 16),
          RatingBarIndicator(
            rating: movie.voteAverage / 2,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: AppTheme.accentColor,
            ),
            itemCount: 5,
            itemSize: 24,
            unratedColor: AppTheme.textSecondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? AppTheme.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDetailsGrid(MovieDetails movie) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date de sortie',
            value: movie.releaseDate ?? 'N/A',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Statut',
            value: movie.status,
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Budget',
            value: movie.budget > 0
                ? '\$${_formatNumber(movie.budget)}'
                : 'Non communiqué',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.trending_up,
            label: 'Revenus',
            value: movie.revenue > 0
                ? '\$${_formatNumber(movie.revenue)}'
                : 'Non communiqué',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.language,
            label: 'Langue originale',
            value: movie.originalLanguage.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCastList(List<CastMember> cast) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      actor.fullProfilePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  actor.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (actor.character != null)
                  Text(
                    actor.character!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsList() {
    return FutureBuilder<SessionResponse>(
      future: _sessionsFuture,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (sessionSnapshot.hasError ||
            !sessionSnapshot.hasData ||
            sessionSnapshot.data!.seances.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_busy,
                  color: AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Aucune séance disponible pour ce film',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        final sessions = sessionSnapshot.data!.seances;

        return Column(
          children: sessions.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectionScreen(seance: session),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.event_seat,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.formattedDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    session.formattedTime,
                                    style:
                                    Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.meeting_room,
                                    size: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Salle ${session.salle}',
                                    style:
                                    Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                  ),
                                ),
                                child: Text(
                                  session.typeSeance,
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${session.prix}€',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.placesDisponibles} places',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ticket_cine/models/movie_details.dart';
import 'package:ticket_cine/models/movie_credit.dart';
import 'package:ticket_cine/models/movie_video.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/views/main/seat_selection_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../theme/app_theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final SessionService _sessionService = SessionService();

  late Future<MovieDetails> _movieDetailsFuture;
  late Future<MovieCredits> _movieCreditsFuture;
  late Future<SessionResponse> _sessionsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _movieService.fetchMovieDetails(widget.movieId);
    _movieCreditsFuture = _movieService.fetchMovieCredits(widget.movieId);
    _sessionsFuture =
        _sessionService.getSeancesByFilm(widget.movieId.toString());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /*Future<void> _showTrailerDialog() async {
    try {
      final videos = await _movieService.fetchMovieVideos(widget.movieId);
      final youtubeVideos =
      videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune bande-annonce disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
        orElse: () => youtubeVideos.firstWhere(
              (v) => v.type == 'Trailer',
          orElse: () => youtubeVideos.firstWhere(
                (v) => v.official,
            orElse: () => youtubeVideos.first,
          ),
        ),
      );

      if (mounted) {
        // Créer le controller en dehors du builder pour une meilleure gestion
        final YoutubePlayerController controller = YoutubePlayerController(
          initialVideoId: trailer.key,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
          ),
        );

        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppTheme.accentColor,
                  progressColors: const ProgressBarColors(
                    playedColor: AppTheme.accentColor,
                    handleColor: AppTheme.primaryColor,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                  onReady: () {
                    print('Player is ready.');
                  },
                  onEnded: (data) {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ),
          ),
        );

        // Disposer le controller après la fermeture du dialog
        controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/

  /*Future<void> _showTrailerDialog() async {
    try {
      final videos = await _movieService.fetchMovieVideos(widget.movieId);
      final youtubeVideos =
      videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune bande-annonce disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
        orElse: () => youtubeVideos.firstWhere(
              (v) => v.type == 'Trailer',
          orElse: () => youtubeVideos.firstWhere(
                (v) => v.official,
            orElse: () => youtubeVideos.first,
          ),
        ),
      );

      if (mounted) {
        // Créer le controller avec des flags optimisés
        final YoutubePlayerController controller = YoutubePlayerController(
          initialVideoId: trailer.key,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            hideControls: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            useHybridComposition: true, // Important pour Android
          ),
        );

        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => WillPopScope(
            onWillPop: () async {
              controller.pause(); // Mettre en pause avant de fermer
              return true;
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  color: Colors.black,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header avec bouton fermer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Colors.black87,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bande-annonce',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                controller.pause();
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Player YouTube
                      YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: AppTheme.accentColor,
                        progressColors: const ProgressBarColors(
                          playedColor: AppTheme.accentColor,
                          handleColor: AppTheme.primaryColor,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                        onReady: () {
                          print('Player is ready.');
                          // Le lecteur va démarrer automatiquement grâce à autoPlay: true
                        },
                        onEnded: (data) {
                          Navigator.of(dialogContext).pop();
                        },
                        bottomActions: [
                          CurrentPosition(),
                          ProgressBar(
                            isExpanded: true,
                            colors: const ProgressBarColors(
                              playedColor: AppTheme.accentColor,
                              handleColor: AppTheme.primaryColor,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                          RemainingDuration(),
                          const PlaybackSpeedButton(),
                          FullScreenButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Disposer le controller après la fermeture du dialog
        controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/


  /*Future<void> _showTrailerDialogIframe() async {
    try {
      final videos = await _movieService.fetchMovieVideos(widget.movieId);
      final youtubeVideos =
      videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune bande-annonce disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final trailer = youtubeVideos.first;

      if (mounted) {
        final controller = YoutubePlayerController.fromVideoId(
          videoId: trailer.key,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
          ),
        );

        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
            ),
          ),
        );

        controller.close();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/


  Future<void> _showTrailerDialog() async {
    try {
      final videos = await _movieService.fetchMovieVideos(widget.movieId);
      final youtubeVideos =
      videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune bande-annonce disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
        orElse: () => youtubeVideos.firstWhere(
              (v) => v.type == 'Trailer',
          orElse: () => youtubeVideos.firstWhere(
                (v) => v.official,
            orElse: () => youtubeVideos.first,
          ),
        ),
      );

      if (mounted) {
        // ✅ Configuration corrigée pour youtube_player_flutter v9
        final YoutubePlayerController controller = YoutubePlayerController(
          initialVideoId: trailer.key,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            hideControls: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            useHybridComposition: true, // Important pour Android
          ),
        );

        // Variable pour tracker si le dialog est fermé
        bool isDialogOpen = true;

        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => WillPopScope(
            onWillPop: () async {
              isDialogOpen = false;
              if (controller.value.isReady) {
                controller.pause();
              }
              return true;
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  color: Colors.black,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header avec bouton fermer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: AppTheme.backgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bande-annonce',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                isDialogOpen = false;
                                if (controller.value.isReady) {
                                  controller.pause();
                                }
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Player YouTube
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppTheme.accentColor,
                          progressColors: const ProgressBarColors(
                            playedColor: AppTheme.accentColor,
                            handleColor: AppTheme.primaryColor,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white12,
                          ),
                          onReady: () {
                            debugPrint('✅ YouTube Player ready');
                            // Le autoPlay se charge automatiquement
                          },
                          onEnded: (data) {
                            if (isDialogOpen) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          // ⚠️ NE PAS utiliser topActions ou bottomActions
                          // car ils peuvent causer des problèmes de type
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Nettoyer après fermeture
        isDialogOpen = false;
        try {
          if (controller.value.isReady) {
            controller.pause();
          }
          await Future.delayed(const Duration(milliseconds: 100));
          controller.dispose();
        } catch (e) {
          debugPrint('Erreur lors du dispose du controller: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FutureBuilder(
        future: Future.wait([_movieDetailsFuture, _movieCreditsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
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
                    'Erreur: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final movie = snapshot.data![0] as MovieDetails;
          final credits = snapshot.data![1] as MovieCredits;

          return CustomScrollView(
            slivers: [
              // AppBar avec image de fond
              SliverAppBar(
                expandedHeight: 500,
                pinned: true,
                backgroundColor: AppTheme.backgroundColor,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropPath != null
                            ? 'https://image.tmdb.org/t/p/w1280${movie.backdropPath}'
                            : 'https://via.placeholder.com/1280x720?text=No+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              AppTheme.backgroundColor,
                            ],
                            stops: [0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Informations en bas
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                movie.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Genres
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie.genres.take(3).map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      genre.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              // Bouton bande-annonce
                              ElevatedButton.icon(
                                onPressed: _showTrailerDialog,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Bande-annonce'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note et informations
                        _buildMovieStats(movie),
                        const SizedBox(height: 24),

                        // Synopsis
                        _buildSection(
                          title: 'Synopsis',
                          child: Text(
                            movie.overview.isNotEmpty
                                ? movie.overview
                                : 'Aucun synopsis disponible',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Détails du film
                        _buildSection(
                          title: 'Détails',
                          child: _buildDetailsGrid(movie),
                        ),
                        const SizedBox(height: 24),

                        // Casting
                        if (credits.cast.isNotEmpty) ...[
                          _buildSection(
                            title: 'Casting principal',
                            child: _buildCastList(credits.cast.take(10).toList()),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Séances disponibles
                        _buildSection(
                          title: 'Séances disponibles',
                          child: _buildSessionsList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMovieStats(MovieDetails movie) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.star,
                value: movie.voteAverage.toStringAsFixed(1),
                label: '${movie.voteCount} votes',
                color: AppTheme.accentColor,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.access_time,
                value: '${movie.runtime ?? 0}',
                label: 'minutes',
                color: AppTheme.textSecondary
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                value: movie.releaseDate?.substring(0, 4) ?? 'N/A',
                label: 'Sortie',
                color: AppTheme.textSecondary
              ),
            ],
          ),
          const SizedBox(height: 16),
          RatingBarIndicator(
            rating: movie.voteAverage / 2,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: AppTheme.accentColor,
            ),
            itemCount: 5,
            itemSize: 24,
            unratedColor: AppTheme.textSecondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? AppTheme.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white
          )
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDetailsGrid(MovieDetails movie) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date de sortie',
            value: movie.releaseDate ?? 'N/A',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Statut',
            value: movie.status,
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Budget',
            value: movie.budget > 0
                ? '\$${_formatNumber(movie.budget)}'
                : 'Non communiqué',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.trending_up,
            label: 'Revenus',
            value: movie.revenue > 0
                ? '\$${_formatNumber(movie.revenue)}'
                : 'Non communiqué',
          ),
          const Divider(height: 24, color: AppTheme.textSecondary),
          _buildDetailRow(
            icon: Icons.language,
            label: 'Langue originale',
            value: movie.originalLanguage.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w400,
                  color: Colors.white
                )
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCastList(List<CastMember> cast) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      actor.fullProfilePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  actor.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (actor.character != null)
                  Text(
                    actor.character!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsList() {
    return FutureBuilder<SessionResponse>(
      future: _sessionsFuture,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (sessionSnapshot.hasError ||
            !sessionSnapshot.hasData ||
            sessionSnapshot.data!.seances.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_busy,
                  color: AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Aucune séance disponible pour ce film',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white
                    )
                  ),
                ),
              ],
            ),
          );
        }

        final sessions = sessionSnapshot.data!.seances;

        return Column(
          children: sessions.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectionScreen(seance: session),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.event_seat,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.formattedDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    session.formattedTime,
                                    style:
                                    Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.meeting_room,
                                    size: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Salle ${session.salle}',
                                    style:
                                    Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                  ),
                                ),
                                child: Text(
                                  session.typeSeance,
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${session.prix}€',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.placesDisponibles} places',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }
}