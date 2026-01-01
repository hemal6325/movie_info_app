import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // লগইন পেজে যাওয়ার জন্য

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // এই ফাংশনটি অনবোর্ডিং শেষ হলে কল হবে
  void _onIntroEnd(context) async {
    // সেভ করে রাখা যে ইউজার অনবোর্ডিং দেখেছে
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    // লগইন পেজে নিয়ে যাওয়া
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // সাধারণ টেক্সট স্টাইল
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.grey);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xFF121212), // অ্যাপের ব্যাকগ্রাউন্ড কালার
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFF121212),
      allowImplicitScrolling: true,
      autoScrollDuration: 3000, // অটোমেটিক স্লাইড হবে

      pages: [
        // স্লাইড ১
        PageViewModel(
          title: "Explore Movies",
          body:
              "Discover millions of movies, TV shows and people. Explore now.",
          image: const Icon(Icons.movie_filter_rounded,
              size: 150, color: Colors.amber),
          decoration: pageDecoration,
        ),
        // স্লাইড ২
        PageViewModel(
          title: "Watch Trailers",
          body:
              "Watch the latest trailers and clips from your favorite movies.",
          image: const Icon(Icons.play_circle_fill,
              size: 150, color: Colors.redAccent),
          decoration: pageDecoration,
        ),
        // স্লাইড ৩
        PageViewModel(
          title: "Track Favorites",
          body: "Save your favorite movies and create your own watchlist.",
          image: const Icon(Icons.favorite_rounded,
              size: 150, color: Colors.pinkAccent),
          decoration: pageDecoration,
        ),
      ],

      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // স্কিপ করলেও শেষ হবে
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,

      // বাটন ডিজাইন
      skip: const Text('Skip',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      next: const Icon(Icons.arrow_forward, color: Colors.white),
      done: const Text('Done',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber)),

      // ডট ইন্ডিকেটর ডিজাইন
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.amber,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
