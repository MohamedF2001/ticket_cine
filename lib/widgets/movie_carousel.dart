import 'package:flutter/material.dart';
import 'package:ticket_cine/models/movie_response.dart';

import '../theme/app_theme.dart';
import '../views/main/movie_details_screen.dart';
import '../views/movie_details.dart';

class MovieCarousel extends StatefulWidget {
  final List<Movie> movies;

  const MovieCarousel({super.key, required this.movies});

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              bool isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 0 : 20,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movieId: movie.id),
                      ),
                    );
                  },
                  child: Hero(
                    // ✅ TAG UNIQUE : ajout de 'carousel' et index
                    tag: 'movie_carousel_${movie.id}_$index',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(
                              isActive ? 0.4 : 0.1,
                            ),
                            blurRadius: isActive ? 30 : 10,
                            spreadRadius: isActive ? 2 : 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image de fond
                            Image.network(
                              movie.fullBackdropUrl,
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
                                    Colors.black87,
                                  ],
                                  stops: [0.5, 1.0],
                                ),
                              ),
                            ),

                            // Infos du film
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: AppTheme.accentColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          movie.voteAverage.toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (movie.releaseDate != null)
                                          Text(
                                              movie.releaseDate!.substring(0, 4),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.textSecondary
                                              )
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MovieDetailScreen(movieId: movie.id),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Voir les détails'),
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
                  ),
                ),
              );
            },
          ),
        ),

        // Indicateurs de page
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.movies.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}


/*
class _MovieCarouselState extends State<MovieCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              bool isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 0 : 20,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movieId: movie.id),
                        //builder: (_) => MovieDetailPagee(movieId: movie.id),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'movie_${movie.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(
                              isActive ? 0.4 : 0.1,
                            ),
                            blurRadius: isActive ? 30 : 10,
                            spreadRadius: isActive ? 2 : 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image de fond
                            Image.network(
                              movie.fullBackdropUrl,
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
                                    Colors.black87,
                                  ],
                                  stops: [0.5, 1.0],
                                ),
                              ),
                            ),

                            // Infos du film
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: AppTheme.accentColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          movie.voteAverage.toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (movie.releaseDate != null)
                                          Text(
                                            movie.releaseDate!.substring(0, 4),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary
                                            )
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MovieDetailScreen(movieId: movie.id),
                                            */
/* MovieDetailPagee(
                                              movieId: movie.id,
                                            ),*//*

                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Voir les détails'),
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
                  ),
                ),
              );
            },
          ),
        ),

        // Indicateurs de page
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.movies.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}*/
