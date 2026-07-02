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
      width: 160,
      margin: const EdgeInsets.only(left: 16, right: 4, bottom: 16),
      child: InkWell(
        onTap: movie == null ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPagee(movieId: movie!.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'movie-poster-${movie?.id ?? UniqueKey()}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (isLoading || movie == null)
                        ? _buildShimmerPlaceholder()
                        : Image.network(
                            'https://image.tmdb.org/t/p/w500${movie!.posterPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.broken_image, color: AppColors.primary),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (movie != null) ...[
              Text(
                movie!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    movie!.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
