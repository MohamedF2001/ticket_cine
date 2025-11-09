/*
import 'package:flutter/material.dart';
import 'package:ticket_cine/models/movie_response.dart';
import 'package:ticket_cine/widgets/movie_card_widget.dart';

import '../theme/app_theme.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingLarge,
            vertical: AppTheme.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation vers la page "Voir tout"
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCardWidget(movie: movies[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/movie_response.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/widgets/movie_card_widget.dart';
import '../theme/app_theme.dart';

class MovieSection extends StatefulWidget {
  final String title;
  final Future<MovieResponse> Function(int page) fetchMovies; // 👈 fonction à fournir
  const MovieSection({
    super.key,
    required this.title,
    required this.fetchMovies,
  });

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection> {
  final List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await widget.fetchMovies(_currentPage);

      setState(() {
        _movies.addAll(response.results);
        _currentPage++;
        _hasMore = response.results.isNotEmpty;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER (Titre + Voir tout)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingLarge,
            vertical: AppTheme.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 👉 Navigation vers la page "Voir tout"
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// LISTE DE FILMS
        SizedBox(
          height: 250,
          child: _movies.isEmpty && _isLoading
              ? const Center(
            child: SpinKitThreeBounce(
              duration: Duration(seconds: 3),
              color: Colors.white70,
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              return MovieCardWidget(movie: _movies[index]);
            },
          ),
        ),

        const SizedBox(height: 8),

        /// BOUTON "CHARGER PLUS"
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _loadMovies,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: SpinKitPulse(
                    duration: Duration(seconds: 3),
                    color: Colors.white70,
                  ),
                )
                    : const Text(
                  'Charger plus',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
