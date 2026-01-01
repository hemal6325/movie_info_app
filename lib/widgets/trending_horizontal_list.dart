import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/details_screen.dart';

class TrendingHorizontalList extends StatelessWidget {
  final List<Movie> movies;

  const TrendingHorizontalList({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320, // কার্ডের হাইট
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (c, i) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final movie = movies[index];
          // রেটিং পার্সেন্টেজ বের করা (7.7 -> 77%)
          final percentage = ((movie.voteAverage ?? 0) * 10).toInt();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailsScreen(movie: movie)),
              );
            },
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // 1. Movie Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://image.tmdb.org/t/p/w342${movie.posterPath}",
                          height: 225,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // 2. Circular Rating (Floating)
                      Positioned(
                        bottom: 5,
                        left: 10,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF081C22),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              "$percentage%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 3. Title
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // 4. Date
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      movie.releaseDate ?? "Unknown",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
