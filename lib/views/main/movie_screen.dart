import 'package:flutter/material.dart';
import 'package:ticket_cine/models/movie_response.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/widgets/movie_carousel.dart';
import 'package:ticket_cine/widgets/movie_section.dart';

import '../../theme/app_theme.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final MovieService _movieService = MovieService();

  late Future<MovieResponse> _nowPlayingFuture;
  late Future<MovieResponse> _popularFuture;
  late Future<MovieResponse> _topRatedFuture;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    _nowPlayingFuture = _movieService.fetchNowPlayingMovies();
    _popularFuture = _movieService.fetchPopularMovies();
    _topRatedFuture = _movieService.fetchTopRatedMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              expandedHeight: 60,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'MoviePass',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Carrousel des films tendances
            SliverToBoxAdapter(
              child: FutureBuilder<MovieResponse>(
                future: _nowPlayingFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MovieCarousel(
                      movies: snapshot.data!.results.take(5).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: Text('Erreur de chargement'),
                      ),
                    );
                  }
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Section En ce moment
            SliverToBoxAdapter(
              child: FutureBuilder<MovieResponse>(
                future: _nowPlayingFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MovieSection(
                      title: 'En ce moment',
                      //movies: snapshot.data!.results,
                      fetchMovies: (page) => MovieService().fetchNowPlayingMovies(page: page),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Section Populaire
            SliverToBoxAdapter(
              child: FutureBuilder<MovieResponse>(
                future: _popularFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MovieSection(
                      title: 'Populaire',
                      //movies: snapshot.data!.results,
                      fetchMovies: (page) => MovieService().fetchNowPlayingMovies(page: page),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Section Les mieux notés
            SliverToBoxAdapter(
              child: FutureBuilder<MovieResponse>(
                future: _topRatedFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MovieSection(
                      title: 'Les mieux notés',
                      //movies: snapshot.data!.results,
                      fetchMovies: (page) => MovieService().fetchNowPlayingMovies(page: page),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Espace en bas
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}