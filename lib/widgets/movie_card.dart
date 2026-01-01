import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/details_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String imageBase;
  final String size;

  const MovieCard({
    required this.movie,
    required this.imageBase,
    this.size = 'w342',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poster =
        movie.posterPath != null ? '$imageBase$size${movie.posterPath}' : null;

    return InkWell(
      onTap: () {
        // 🔥 FIXED: সরাসরি মুভি অবজেক্ট পাঠানো হচ্ছে
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(movie: movie),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: poster != null
                // 🔥 Hero Animation যোগ করা হয়েছে
                ? Hero(
                    tag: movie.id, // ইউনিক ট্যাগ (মুভি আইডি)
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: poster,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (c, s) =>
                            Container(color: Colors.grey[900]),
                        errorWidget: (c, s, e) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : Container(color: Colors.grey[900]),
          ),
          const SizedBox(height: 8),

          // Movie Title
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Rating Row
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                movie.voteAverage?.toStringAsFixed(1) ?? "N/A",
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
