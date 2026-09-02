import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '6654793a6f7467d2c7d61cc4ccbb260e';

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  Future<List<Movie>> getMovies() async {
    _currentPage = 1;
    _hasMore = true;

    return await _fetchPage(_currentPage);
  }

  Future<List<Movie>> loadMoreMovies() async {
    if (!_hasMore) return [];

    _currentPage++;

    return await _fetchPage(_currentPage);
  }

  Future<List<Movie>> _fetchPage(int page) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie'
          '?api_key=$_apiKey'
          '&with_genres=16'
          '&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        
        _totalPages = data['total_pages'] ?? 1;

       
        _hasMore = _currentPage < _totalPages;

        List<Movie> movies = [];

        if (data['results'] != null) {
          for (var item in data['results']) {
            movies.add(Movie.fromJson(item));
          }
        }

        return movies;
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId'
          '?api_key=$_apiKey'
          '&append_to_response=credits',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/movie'
          '?api_key=$_apiKey'
          '&query=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Movie> movies = [];

        if (data['results'] != null) {
          for (var item in data['results']) {
            movies.add(Movie.fromJson(item));
          }
        }

        return movies;
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

 
  void resetPagination() {
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
  }

  bool get hasMore => _hasMore;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;
}