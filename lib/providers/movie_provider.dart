import 'package:flutter/material.dart';
import '../controllers/movie_controller.dart';
import '../models/movie_model.dart';

class MovieProvider extends ChangeNotifier {
  final MovieController _movieController = MovieController();

  
  List<Movie> get movies => _movieController.movies;
  List<Movie> get favorites => _movieController.favorites;
  List<Movie> get watched => _movieController.watched;
  List<Movie> get watching => _movieController.watching;
  List<Movie> get wantToWatch => _movieController.wantToWatch;

  bool get isLoading => _movieController.isLoading;
  bool get isLoadingMore => _movieController.isLoadingMore;
  bool get hasMore => _movieController.hasMore;
  String? get errorMessage => _movieController.errorMessage;


  Future<void> fetchMovies() async {
    await _movieController.fetchMovies();
    notifyListeners();
  }

  Future<void> loadMoreMovies() async {
    await _movieController.loadMoreMovies();
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    await _movieController.fetchFavorites();
    notifyListeners();
  }

  Future<void> fetchWatched() async {
    await _movieController.fetchWatched();
    notifyListeners();
  }

  Future<void> fetchWatching() async {
    await _movieController.fetchWatching();
    notifyListeners();
  }


  Future<void> fetchWantToWatch() async {
    await _movieController.fetchWantToWatch();
    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    await _movieController.toggleFavorite(movie);
    notifyListeners();
  }

  Future<void> startWatching(Movie movie) async {
    await _movieController.startWatching(movie);
    notifyListeners();
  }

  Future<void> markAsWatched(Movie movie) async {
    await _movieController.markAsWatched(movie);
    notifyListeners();
  }


  Future<void> addToWantToWatch(Movie movie) async {
    await _movieController.addToWantToWatch(movie);
    notifyListeners();
  }

  Future<void> removeFromWantToWatch(Movie movie) async {
    await _movieController.removeFromWantToWatch(movie);
    notifyListeners();
  }

  Future<List<Movie>> searchMovies(String query) async {
    return await _movieController.searchMovies(query);
  }


  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return await _movieController.getMovieDetails(movieId);
  }

  void clearError() {
    _movieController.clearError();
    notifyListeners();
  }
}