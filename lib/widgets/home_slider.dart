import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/details_screen.dart';

class HomeSlider extends StatelessWidget {
  final List<Movie> movies;

  const HomeSlider({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0, // স্লাইডারের উচ্চতা
        autoPlay: true, // অটোমেটিক স্লাইড হবে
        enlargeCenterPage: true, // মাঝখানের ছবিটা একটু বড় দেখাবে
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: movies.map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                // স্লাইডারে ক্লিক করলে ডিটেইলস পেজে যাবে
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(movie: movie),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Image
                      movie.backdropPath != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  "https://image.tmdb.org/t/p/w780${movie.backdropPath}", // w780 হলো একটু ভালো কোয়ালিটির জন্য
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : Container(color: Colors.grey),

                      // ছবির ওপর কালো শেড (Gradient) যাতে লেখা বোঝা যায়
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Movie Title on Slider
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
