import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<MovieProvider>(context).favorites;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "My Watchlist",
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No favorites yet!",
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: favorites[index],
                  imageBase: 'https://image.tmdb.org/t/p/',
                  size: 'w342',
                );
              },
            ),
    );
  }
}
