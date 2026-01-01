import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/movie.dart';
import '../models/person.dart';

class TmdbService {
  final ApiClient apiClient;

  TmdbService(this.apiClient);

  // ১. পপুলার মুভি
  Future<List<Movie>> fetchPopular({int page = 1}) async {
    final res = await apiClient.get('/movie/popular', params: {'page': page});
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ২. মুভি সার্চ
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final res = await apiClient.get(
      '/search/movie',
      params: {'query': query, 'page': page},
    );
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ৩. ক্যাটাগরি অনুযায়ী মুভি
  Future<List<Movie>> fetchMoviesByGenre(int genreId, {int page = 1}) async {
    final res = await apiClient.get(
      '/discover/movie',
      params: {
        'with_genres': genreId,
        'page': page,
        'sort_by': 'popularity.desc',
      },
    );
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ৪. মুভি ডিটেইলস
  Future<Movie> fetchMovieDetails(int id) async {
    final res = await apiClient.get(
      '/movie/$id',
      params: {'append_to_response': 'videos,credits'},
    );
    return Movie.fromJson(res.data);
  }

  // ৫. সিমিলার মুভি
  Future<List<Movie>> fetchSimilarMovies(int id) async {
    final res = await apiClient.get('/movie/$id/similar');
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ৬. অভিনেতার ডিটেইলস
  Future<Person> fetchPersonDetails(int personId) async {
    final res = await apiClient.get('/person/$personId');
    return Person.fromJson(res.data);
  }

  // ৭. অভিনেতার অন্যান্য মুভি
  Future<List<Movie>> fetchPersonMovies(int personId) async {
    final res = await apiClient.get('/person/$personId/movie_credits');
    final results = res.data['cast'] as List;
    results.sort(
      (a, b) => (b['popularity'] ?? 0).compareTo(a['popularity'] ?? 0),
    );
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ৮. ট্রেন্ডিং মুভি
  Future<List<Movie>> fetchTrending(String timeWindow) async {
    final res = await apiClient.get('/trending/movie/$timeWindow');
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // 🔥 ৯. আপকামিং মুভি (NEW)
  Future<List<Movie>> fetchUpcoming() async {
    final res = await apiClient.get('/movie/upcoming');
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // 🔥 ১০. টপ রেটেড মুভি (NEW)
  Future<List<Movie>> fetchTopRated() async {
    final res = await apiClient.get('/movie/top_rated');
    final results = res.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }
}
