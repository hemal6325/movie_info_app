import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../screens/details_screen.dart';

class MovieSearchDelegate extends SearchDelegate {
  final TmdbService service;

  MovieSearchDelegate(this.service);

  // ১. সার্চ বারের থিম এবং কালার ঠিক করা
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212), // অ্যাপের কালার
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212), // বডি কালার
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.amber,
      ),
    );
  }

  // ২. সার্চ বারের ডানদিকের বাটন (Clear Button)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = ''; // লেখা মুছে ফেলবে
            showSuggestions(context); // আবার সাজেস্ট দেখাবে
          },
        ),
    ];
  }

  // ৩. বামদিকের বাটন (Back Button)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.amber),
      onPressed: () => close(context, null), // সার্চ বন্ধ করবে
    );
  }

  // ৪. যখন ইউজার এন্টার চাপবে (Results)
  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context); // আমরা রেজাল্ট আর সাজেস্ট একই রাখব
  }

  // 🔥 ৫. আসল ম্যাজিক: টাইপ করার সাথে সাথে সাজেস্ট করবে
  @override
  Widget buildSuggestions(BuildContext context) {
    // যদি ইউজার কিছু না লেখে, তবে ডিফল্ট কিছু দেখাবো (যেমন Trending)
    if (query.isEmpty) {
      return FutureBuilder<List<Movie>>(
        future: service.fetchPopular(), // কিছু না লিখলে পপুলার মুভি দেখাবে
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          return _buildMovieList(context, snapshot.data!, isTrending: true);
        },
      );
    }

    // ইউজার টাইপ করলে API কল হবে
    return FutureBuilder<List<Movie>>(
      future: service.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 80, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  "No movies found for '$query'",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return _buildMovieList(context, snapshot.data!, isTrending: false);
      },
    );
  }

  // 🔥 ৬. মুভি লিস্ট বানানোর হেল্পার উইজেট
  Widget _buildMovieList(
    BuildContext context,
    List<Movie> movies, {
    required bool isTrending,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTrending)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "🔥 Popular Searches",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        Expanded(
          child: ListView.separated(
            itemCount: movies.length,
            separatorBuilder: (c, i) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              "https://image.tmdb.org/t/p/w92${movie.posterPath}",
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          placeholder: (c, u) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (c, u, e) =>
                              const Icon(Icons.movie, color: Colors.grey),
                        )
                      : Container(
                          width: 50,
                          height: 75,
                          color: Colors.grey[900],
                          child: const Icon(Icons.movie),
                        ),
                ),
                title: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage?.toStringAsFixed(1) ?? "N/A",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      movie.releaseDate?.split('-')[0] ?? "", // শুধু সাল দেখাবে
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // ডিটেইলস পেজে নিয়ে যাবে
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsScreen(movie: movie),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
