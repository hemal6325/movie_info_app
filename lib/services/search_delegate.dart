import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../screens/details_screen.dart';

class MovieSearchDelegate extends SearchDelegate {
  final TmdbService service;

  MovieSearchDelegate(this.service);

  // ডার্ক মোড থিম সেটআপ
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212)),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.amber,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: service.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No movies found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        final movies = snapshot.data!;
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: movie.posterPath != null
                  ? Image.network(
                      "https://image.tmdb.org/t/p/w92${movie.posterPath}",
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.movie, color: Colors.grey),
              title: Text(
                movie.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                movie.releaseDate ?? 'Unknown',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(movie: movie),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.white12),
          SizedBox(height: 10),
          Text("Search for movies...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
