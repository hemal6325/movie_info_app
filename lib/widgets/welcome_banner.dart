import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../services/movie_search_delegate.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // প্রোভাইডার থেকে লোকাল ইমেজের পাথ নিচ্ছি
    final imagePath = Provider.of<MovieProvider>(context).bannerImagePath;

    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 🔥 1. লোকাল ইমেজ লোড করা
          if (imagePath != null)
            Image.asset(imagePath, fit: BoxFit.cover)
          else
            Container(
              color: const Color(0xFF032541),
            ), // ইমেজ না পেলে ডিফল্ট কালার
          // 2. নীল রঙের আস্তরণ (Overlay)
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(3, 37, 65, 0.8),
            ),
          ),

          // 3. টেক্সট এবং সার্চ বার (আগের মতোই)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome.",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Millions of movies, TV shows and people to discover. Explore now.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // 🔍 সার্চ বার
                GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: MovieSearchDelegate(
                        Provider.of<MovieProvider>(
                          context,
                          listen: false,
                        ).service,
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          "Search for a movie...",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1ED5A9), Color(0xFF01B4E4)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
