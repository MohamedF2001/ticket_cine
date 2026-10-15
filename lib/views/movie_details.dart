import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/views/video_section.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie_credit.dart';
import '../models/movie_details.dart';
import '../services/movie_service.dart';

class MovieDetailPagee extends StatefulWidget {
  final int movieId;

  const MovieDetailPagee({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieDetailPageeState createState() => _MovieDetailPageeState();
}

class _MovieDetailPageeState extends State<MovieDetailPagee>
    with TickerProviderStateMixin {
  late Future<MovieDetails> _movieDetails;
  late Future<MovieCredits> _movieCredits;
  final MovieService _movieService = MovieService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _movieDetails = _movieService.fetchMovieDetails(widget.movieId);
    _movieCredits = _movieService.fetchMovieCredits(widget.movieId);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
              title: const Text('Détails'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: FutureBuilder(
          future: Future.wait([_movieDetails, _movieCredits]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found'));
            }

            final movie = snapshot.data![0] as MovieDetails;
            final credits = snapshot.data![1] as MovieCredits;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Détails du film
                  _buildMovieHeader(movie),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        //_buildAnimatedSection( _buildGenresSection(movie),),
                        //const SizedBox(height: 30),
                        _buildAnimatedSection(_buildDetailsSection(movie)),
                        const SizedBox(height: 30),

                        _buildAnimatedSection(
                          VideoSection(
                            movieId: widget.movieId,
                            movieService: _movieService,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTrailerDialog(BuildContext context, int movieId) async {
    try {
      final videos = await _movieService.fetchMovieVideos(movieId);
      final youtubeVideos = videos.results.where((v) => v.site == 'YouTube').toList();

      if (youtubeVideos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune bande-annonce disponible')),
        );
        return;
      }

      // On prend la première vidéo de type "Trailer" ou la première vidéo YouTube
      /*final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer',
        orElse: () => youtubeVideos.first,
      );*/

      // Dans _showTrailerDialog:
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

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: trailer.key,
                flags: const YoutubePlayerFlags(
                  autoPlay: true,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              progressColors: const ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Container(height: 550, width: double.infinity, color: Colors.white),
            const SizedBox(height: 20),

            // Overview shimmer
            Container(width: double.infinity, height: 20, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 300, height: 16, color: Colors.white),
            const SizedBox(height: 30),

            // Genres shimmer
            Container(width: 100, height: 20, color: Colors.white),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 30,
                  color: Colors.white,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Container(
                  width: 60,
                  height: 30,
                  color: Colors.white,
                  margin: const EdgeInsets.only(right: 8),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Details shimmer
            Container(width: 100, height: 20, color: Colors.white),
            const SizedBox(height: 8),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 24, height: 24, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 100, height: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 150, height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Cast shimmer
            Container(width: 100, height: 20, color: Colors.white),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 8,
              itemBuilder:
                  (_, __) => Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(width: 60, height: 12, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 50, height: 10, color: Colors.white),
                    ],
                  ),
            ),
            const SizedBox(height: 30),

            // Crew shimmer
            Container(width: 100, height: 20, color: Colors.white),
            const SizedBox(height: 10),
            ...List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 100,
                    height: 18,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 150,
                            height: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(_fadeAnimation),
      child: child,
    );
  }

  Widget _buildMovieHeader(MovieDetails movie) {
    return Stack(
      children: [
        Hero(
          tag: 'movie_${movie.id}',
          child: Container(
            height: 550,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: 550,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.backgroundColor.withOpacity(0.5),
                AppTheme.backgroundColor,
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 24,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  movie.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: _buildGenresSection(movie),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  movie.overview,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showTrailerDialog(context, widget.movieId),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Bande-annonce'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMovieOverview(MovieDetails movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //_buildSectionTitle('Aperçu'),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildGenresSection(MovieDetails movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              movie.genres
                  .map(
                    (genre) => Chip(
                      label: Text(genre.name),
                      backgroundColor: Colors.grey[800],
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(MovieDetails movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Détails'),
        const SizedBox(height: 8),
        _buildDetailRow(
          Icons.calendar_today,
          'Date de sortie',
          movie.releaseDate ?? 'N/A',
        ),
        const SizedBox(height: 5),
        _buildDetailRow(Icons.timer, 'Durée', '${movie.runtime ?? 0} min'),
        const SizedBox(height: 5),
        _buildDetailRow(Icons.info_outline, 'Statut', movie.status),
        const SizedBox(height: 5),
        _buildDetailRow(
          Icons.attach_money,
          'Budget',
          '\$${movie.budget.toStringAsFixed(0)}',
        ),
        const SizedBox(height: 5),
        _buildDetailRow(Icons.star, 'Notation', ''),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: RatingBarIndicator(
            rating: movie.voteAverage / 2,
            itemBuilder:
                (context, _) => const Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 24,
            unratedColor: Colors.white24,
            direction: Axis.horizontal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(
            '${movie.voteAverage}/10 (${movie.voteCount} votes)',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Expanded(
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(color: Colors.white)),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCastGrid(List<CastMember> cast) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cast.length,
      itemBuilder: (context, index) {
        final actor = cast[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(actor.fullProfilePath),
            ),
            SizedBox(height: 5),
            Text(
              actor.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              actor.character ?? 'Unknown',
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCrewByDepartment(List<CrewMember> crew) {
    final departments = {
      'Direction': crew.where((p) => p.department == 'Directing').toList(),
      'Ecriture': crew.where((p) => p.department == 'Writing').toList(),
      'Production': crew.where((p) => p.department == 'Production').toList(),
      'Caméra': crew.where((p) => p.department == 'Camera').toList(),
      'Son': crew.where((p) => p.department == 'Sound').toList(),
      'Art': crew.where((p) => p.department == 'Art').toList(),
      'Édition': crew.where((p) => p.department == 'Editing').toList(),
      'Costume et maquillage':
          crew.where((p) => p.department == 'Costume & Make-Up').toList(),
      'Effets visuels':
          crew.where((p) => p.department == 'Visual Effects').toList(),
      'Équipe': crew.where((p) => p.department == 'Crew').toList(),
    };

    return Column(
      children:
          departments.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map(
                  (person) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            person.job,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            person.name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
    );
  }
}
