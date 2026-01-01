import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart'; // এটা আর লাগছে না, তাই বাদ দিতে পারো
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import 'actor_details_screen.dart';
import 'trailer_player_screen.dart'; // 🔥 ভিডিও প্লেয়ার স্ক্রিন ইমপোর্ট

class DetailsScreen extends StatelessWidget {
  final Movie movie;

  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          Consumer<MovieProvider>(
            builder: (context, provider, child) {
              final isFav = provider.isFavorite(movie.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 30,
                ),
                onPressed: () {
                  provider.toggleFavorite(movie);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav ? "Removed from Favorites" : "Added to Favorites",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey[900],
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. পোস্টার (Hero Animation সহ)
            if (movie.posterPath != null)
              Hero(
                tag: movie.id,
                child: Image.network(
                  "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300, // ফিক্সড হাইট দিলে লোডিং স্মুথ হয়
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              )
            else
              const SizedBox(
                height: 300,
                child: Center(
                  child: Icon(Icons.movie, color: Colors.white, size: 50),
                ),
              ),

            const SizedBox(height: 20),

            // ২. টাইটেল
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ৩. রেটিং
            Center(
              child: Text(
                "Rating: ${movie.voteAverage?.toStringAsFixed(1) ?? 'N/A'} ⭐",
                style: const TextStyle(color: Colors.amber, fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // ৪. ওভারভিউ
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                movie.overview ?? "No Description Available",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 25),

            // ৫. ট্রেইলার এবং কাস্ট (ডাটা ফেচ করা হচ্ছে)
            FutureBuilder<Movie>(
              future: Provider.of<MovieProvider>(
                context,
                listen: false,
              ).service.fetchMovieDetails(movie.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                if (snapshot.hasError) return const SizedBox();

                final fullMovie = snapshot.data;
                final hasTrailer = fullMovie?.trailerId != null &&
                    fullMovie!.trailerId!.isNotEmpty;
                final hasCast =
                    fullMovie?.cast != null && fullMovie!.cast!.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Trailer Button Logic (In-App Player Update)
                    Center(
                      child: hasTrailer
                          ? ElevatedButton.icon(
                              onPressed: () {
                                // 🔥 অ্যাপের ভেতরেই ভিডিও প্লেয়ার ওপেন হবে
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TrailerPlayerScreen(
                                      videoId: fullMovie!.trailerId!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                              ),
                              label: const Text("Watch Trailer"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey[800]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.videocam_off, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "No Trailer Available",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),

                    // Cast List
                    if (hasCast) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Cast",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: fullMovie!.cast!.length > 10
                              ? 10
                              : fullMovie.cast!.length,
                          separatorBuilder: (c, i) => const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final actor = fullMovie.cast![index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActorDetailsScreen(
                                      personId: actor.id,
                                      personName: actor.name,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage: actor.profilePath != null
                                        ? NetworkImage(
                                            "https://image.tmdb.org/t/p/w185${actor.profilePath}",
                                          )
                                        : null,
                                    child: actor.profilePath == null
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      actor.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ৬. সিমিলার মুভিজ
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "You May Also Like",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Movie>>(
              future: Provider.of<MovieProvider>(
                context,
                listen: false,
              ).service.fetchSimilarMovies(movie.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "No similar movies found.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final similarMovies = snapshot.data!;
                return SizedBox(
                  height: 250,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: similarMovies.length,
                    separatorBuilder: (c, i) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final m = similarMovies[index];
                      return SizedBox(
                        width: 140,
                        child: MovieCard(
                          movie: m,
                          imageBase: 'https://image.tmdb.org/t/p/',
                          size: 'w342',
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
