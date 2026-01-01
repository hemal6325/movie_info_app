import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TmdbService service;

  List<Movie> popular = [];
  List<Movie> trending = [];
  List<Movie> favorites = [];

  bool isLoading = false;
  int page = 1;
  int _selectedGenreId = 0;

  // 🔥 নতুন: এখন আমাদের ৪টি অপশন, তাই নাম দিলাম trendingTab
  // অপশনগুলো: 'day', 'week', 'upcoming', 'top_rated'
  String _trendingTab = 'day';
  String get trendingTab => _trendingTab;

  final List<String> _localImages = [
    'assets/images/bg01.jpg',
    'assets/images/bg02.jpg',
    'assets/images/bg03.jpg',
    'assets/images/bg04.jpg',
  ];

  String? _bannerImagePath;
  String? get bannerImagePath => _bannerImagePath;

  int get selectedGenreId => _selectedGenreId;

  MovieProvider(this.service) {
    loadFavorites();
    setRandomBannerImage();
  }

  void setRandomBannerImage() {
    if (_localImages.isNotEmpty) {
      final randomIndex = Random().nextInt(_localImages.length);
      _bannerImagePath = _localImages[randomIndex];
    }
  }

  Future<void> loadPopular({bool refresh = false}) async {
    try {
      if (refresh) {
        page = 1;
        popular.clear();
        trending.clear();
        _selectedGenreId = 0;
        _trendingTab = 'day'; // ডিফল্টভাবে 'Today' তে রিসেট হবে
        setRandomBannerImage();
      }

      isLoading = true;
      notifyListeners();

      final popMovies = _selectedGenreId == 0
          ? await service.fetchPopular(page: page)
          : await service.fetchMoviesByGenre(_selectedGenreId, page: page);

      if (page == 1) {
        // ডিফল্ট ডাটা লোড (Today)
        trending = await service.fetchTrending('day');
      }

      if (refresh) {
        popular = popMovies;
      } else {
        popular.addAll(popMovies);
      }

      isLoading = false;
      page++;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 🔥 নতুন: ৪টি ট্যাবের লজিক হ্যান্ডেল করার ফাংশন
  Future<void> setTrendingTab(String tab) async {
    _trendingTab = tab;
    notifyListeners(); // লোডিং দেখানোর জন্য বা বাটন হাইলাইট করার জন্য

    List<Movie> newMovies = [];

    if (tab == 'day') {
      newMovies = await service.fetchTrending('day');
    } else if (tab == 'week') {
      newMovies = await service.fetchTrending('week');
    } else if (tab == 'upcoming') {
      newMovies = await service.fetchUpcoming();
    } else if (tab == 'top_rated') {
      newMovies = await service.fetchTopRated();
    }

    trending = newMovies;
    notifyListeners();
  }

  Future<void> setGenre(int genreId) async {
    _selectedGenreId = genreId;
    popular.clear();
    page = 1;
    await loadPopular();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('favorites');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      favorites = jsonList.map((e) => Movie.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final isExist = favorites.any((element) => element.id == movie.id);
    if (isExist) {
      favorites.removeWhere((element) => element.id == movie.id);
    } else {
      favorites.add(movie);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString('favorites', data);
  }

  bool isFavorite(int id) {
    return favorites.any((element) => element.id == id);
  }
}
