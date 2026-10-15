import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticket_cine/models/movie_response.dart';
import 'package:ticket_cine/theme/app_theme.dart';

import '../views/movie_details.dart';

class MovieCard extends StatelessWidget {
  final Movie? movie;
  final bool isLoading;

  const MovieCard({Key? key, this.movie, this.isLoading = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading || movie == null)
            _buildShimmerPlaceholder()
          else
            _buildMovieContent(context),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 260,
            width: 170,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 150, height: 16, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Container(width: 40, height: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildMovieContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPagee(movieId: movie!.id),
              ),
            );
          },
          child: Stack(
            children: [
              Hero(
                tag: 'movie_${movie!.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie!.posterPath}',
                    height: 260,
                    width: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 260,
                      width: 170,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black.withOpacity(0.5),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.accentColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            movie!.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie!.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          movie!.releaseDate?.split('-').first ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
