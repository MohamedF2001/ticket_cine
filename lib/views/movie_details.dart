import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
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

class _MovieDetailPageeState extends State<MovieDetailPagee> {
  late Future<MovieDetails> _movieDetails;
  late Future<MovieCredits> _movieCredits;
  final MovieService _movieService = MovieService();

  @override
  void initState() {
    super.initState();
    _movieDetails = _movieService.fetchMovieDetails(widget.movieId);
    _movieCredits = _movieService.fetchMovieCredits(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: Future.wait([_movieDetails, _movieCredits]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found', style: TextStyle(color: Colors.white)));
          }

          final movie = snapshot.data![0] as MovieDetails;
          final credits = snapshot.data![1] as MovieCredits;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(movie),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: _buildMainInfo(movie),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildGenres(movie),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildOverview(movie),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildCast(credits.cast),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: VideoSection(
                          movieId: widget.movieId,
                          movieService: _movieService,
                        ),
                      ),
                      const SizedBox(height: 50),
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

  Widget _buildSliverAppBar(MovieDetails movie) {
    return SliverAppBar(
      expandedHeight: 500,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie-poster-${movie.id}',
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                fit: BoxFit.cover,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                    AppColors.background,
                  ],
                  stops: [0.6, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.play_circle_fill, size: 32, color: AppColors.primary),
          onPressed: () => _showTrailerDialog(context, widget.movieId),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainInfo(MovieDetails movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoTile(Icons.calendar_today_rounded, movie.releaseDate?.split('-')[0] ?? 'N/A'),
        _infoTile(Icons.timer_outlined, '${movie.runtime} min'),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildGenres(MovieDetails movie) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: movie.genres.map((genre) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          genre.name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      )).toList(),
    );
  }

  Widget _buildOverview(MovieDetails movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          movie.overview,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCast(List<CastMember> cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Casting',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length.clamp(0, 15),
            itemBuilder: (context, index) {
              final actor = cast[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(actor.fullProfilePath),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      actor.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

      final trailer = youtubeVideos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
        orElse: () => youtubeVideos.firstWhere(
              (v) => v.type == 'Trailer',
          orElse: () => youtubeVideos.first,
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          content: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: trailer.key,
                flags: const YoutubePlayerFlags(autoPlay: true),
              ),
              showVideoProgressIndicator: true,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 500, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(height: 20, width: 200, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(height: 100, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
