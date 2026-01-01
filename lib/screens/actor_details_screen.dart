import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class ActorDetailsScreen extends StatelessWidget {
  final int personId;
  final String personName;

  const ActorDetailsScreen({
    super.key,
    required this.personId,
    required this.personName,
  });

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MovieProvider>(context, listen: false).service;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(personName),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: FutureBuilder<Person>(
        future: service.fetchPersonDetails(personId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading details",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final person = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                CircleAvatar(
                  radius: 70,
                  backgroundImage: person.profilePath != null
                      ? NetworkImage(
                          "https://image.tmdb.org/t/p/w500${person.profilePath}",
                        )
                      : null,
                  backgroundColor: Colors.grey[800],
                  child: person.profilePath == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),

                // Name & Info
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (person.birthday != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Born: ${person.birthday} ${person.placeOfBirth != null ? 'in ${person.placeOfBirth}' : ''}",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // Biography
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Biography",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    person.biography ?? "No biography available.",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 20),

                // Known For (Movies)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Known For",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<Movie>>(
                  future: service.fetchPersonMovies(personId),
                  builder: (context, movieSnap) {
                    if (!movieSnap.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final movies = movieSnap.data!;
                    if (movies.isEmpty)
                      return const Text(
                        "No movies found",
                        style: TextStyle(color: Colors.white),
                      );

                    return SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        separatorBuilder: (c, i) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 140,
                            child: MovieCard(
                              movie: movies[index],
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
          );
        },
      ),
    );
  }
}
