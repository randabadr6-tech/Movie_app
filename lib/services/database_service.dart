import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<List<Movie>> _getMovies(String key) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(data);

      return jsonList
          .map((item) => Movie.fromMap(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveMovies(
    String key,
    List<Movie> movies,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = movies
        .map((movie) => movie.toMap())
        .toList();

    await prefs.setString(
      key,
      json.encode(jsonList),
    );
  }

  Future<void> addToFavorites(Movie movie) async {
    final favorites = await _getMovies('favorites');

    favorites.removeWhere(
      (m) => m.id == movie.id,
    );

    movie.isFavorite = true;

    favorites.add(movie);

    await _saveMovies(
      'favorites',
      favorites,
    );
  }

  Future<void> removeFromFavorites(int movieId) async {
    final favorites = await _getMovies('favorites');

    favorites.removeWhere(
      (m) => m.id == movieId,
    );

    await _saveMovies(
      'favorites',
      favorites,
    );
  }

  Future<List<Movie>> getFavorites() async {
    return await _getMovies('favorites');
  }

  Future<bool> isFavorite(int movieId) async {
    final favorites = await _getMovies('favorites');

    return favorites.any(
      (movie) => movie.id == movieId,
    );
  }

  Future<void> addToWatched(Movie movie) async {
    // Remove from other statuses
    final wantToWatch = await _getMovies('want_to_watch');

    wantToWatch.removeWhere(
      (m) => m.id == movie.id,
    );

    await _saveMovies(
      'want_to_watch',
      wantToWatch,
    );

    final continueWatching =
        await _getMovies('continue_watching');

    continueWatching.removeWhere(
      (m) => m.id == movie.id,
    );

    await _saveMovies(
      'continue_watching',
      continueWatching,
    );

    movie.isWatched = true;
    movie.isWatching = false;
    movie.isWantToWatch = false;
    movie.watchedDate = DateTime.now();

    final watched = await _getMovies('watched');

    watched.removeWhere(
      (m) => m.id == movie.id,
    );

    watched.add(movie);

    await _saveMovies(
      'watched',
      watched,
    );
  }

  Future<List<Movie>> getWatched() async {
    return await _getMovies('watched');
  }

  Future<bool> isWatched(int movieId) async {
    final watched = await _getMovies('watched');

    return watched.any(
      (movie) => movie.id == movieId,
    );
  }

  
  Future<void> startWatching(Movie movie) async {
    // Remove from Wish List
    final wantToWatch = await _getMovies('want_to_watch');

    wantToWatch.removeWhere(
      (m) => m.id == movie.id,
    );

    await _saveMovies(
      'want_to_watch',
      wantToWatch,
    );

    movie.isWatching = true;
    movie.isWatched = false;
    movie.isWantToWatch = false;
    movie.startWatchingDate = DateTime.now();

    final continueWatching =
        await _getMovies('continue_watching');

    continueWatching.removeWhere(
      (m) => m.id == movie.id,
    );

    continueWatching.add(movie);

    await _saveMovies(
      'continue_watching',
      continueWatching,
    );
  }

  Future<List<Movie>> getContinueWatching() async {
    final continueWatching =
        await _getMovies('continue_watching');

    return continueWatching
        .where(
          (movie) =>
              movie.isWatching &&
              !movie.isWatched,
        )
        .toList();
  }

  Future<bool> isWatching(int movieId) async {
    final continueWatching =
        await _getMovies('continue_watching');

    return continueWatching.any(
      (movie) => movie.id == movieId,
    );
  }


  Future<void> addToWantToWatch(Movie movie) async {
    // Remove from Continue Watching
    final continueWatching =
        await _getMovies('continue_watching');

    continueWatching.removeWhere(
      (m) => m.id == movie.id,
    );

    await _saveMovies(
      'continue_watching',
      continueWatching,
    );

    
    final watched = await _getMovies('watched');

    watched.removeWhere(
      (m) => m.id == movie.id,
    );

    await _saveMovies(
      'watched',
      watched,
    );

    
    movie.isWantToWatch = true;
    movie.isWatched = false;
    movie.isWatching = false;
    movie.wantToWatchDate = DateTime.now();

   
    final wantToWatch = await _getMovies('want_to_watch');

    wantToWatch.removeWhere(
      (m) => m.id == movie.id,
    );

    wantToWatch.add(movie);

    await _saveMovies(
      'want_to_watch',
      wantToWatch,
    );
  }

  Future<void> removeFromWantToWatch(int movieId) async {
    final wantToWatch = await _getMovies('want_to_watch');

    wantToWatch.removeWhere(
      (m) => m.id == movieId,
    );

    await _saveMovies(
      'want_to_watch',
      wantToWatch,
    );
  }

  Future<List<Movie>> getWantToWatch() async {
    return await _getMovies('want_to_watch');
  }

  Future<bool> isWantToWatch(int movieId) async {
    final wantToWatch = await _getMovies('want_to_watch');

    return wantToWatch.any(
      (movie) => movie.id == movieId,
    );
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('favorites');
    await prefs.remove('watched');
    await prefs.remove('continue_watching');
    await prefs.remove('want_to_watch');
  }
}