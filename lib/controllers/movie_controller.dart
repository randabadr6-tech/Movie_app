
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../services/database_service.dart';

class MovieController {
  final TmdbService _tmdbService = TmdbService();
  final DatabaseService _dbService = DatabaseService();

  List<Movie> _movies = [];
  List<Movie> _favorites = [];
  List<Movie> _watched = [];
  List<Movie> _watching = [];
  List<Movie> _wantToWatch = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  
  List<Movie> get movies => _movies;
  List<Movie> get favorites => _favorites;
  List<Movie> get watched => _watched;
  List<Movie> get watching => _watching;
  List<Movie> get wantToWatch => _wantToWatch;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _tmdbService.hasMore;

  Future<void> fetchMovies() async {
    _isLoading = true;
    _errorMessage = null;

    try {
      _tmdbService.resetPagination();

      final fetchedMovies = await _tmdbService.getMovies();

      for (var movie in fetchedMovies) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);

        movie.isWatched =
            await _dbService.isWatched(movie.id);

        movie.isWatching =
            await _dbService.isWatching(movie.id);

        movie.isWantToWatch =
            await _dbService.isWantToWatch(movie.id);
      }

      _movies = fetchedMovies;
    } catch (e) {
      _errorMessage = 'Failed to load movies: $e';
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMoreMovies() async {
    if (_isLoadingMore || !_tmdbService.hasMore) {
      return;
    }

    _isLoadingMore = true;

    try {
      final moreMovies =
          await _tmdbService.loadMoreMovies();

      if (moreMovies.isEmpty) {
        return;
      }

      for (var movie in moreMovies) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);

        movie.isWatched =
            await _dbService.isWatched(movie.id);

        movie.isWatching =
            await _dbService.isWatching(movie.id);

        movie.isWantToWatch =
            await _dbService.isWantToWatch(movie.id);
      }

      _movies.addAll(moreMovies);
    } catch (e) {
      _errorMessage = 'Failed to load more movies: $e';
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchFavorites() async {
    try {
      _favorites =
          await _dbService.getFavorites();
    } catch (e) {
      _errorMessage =
          'Failed to load favorites: $e';
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    try {
      if (movie.isFavorite) {
        await _dbService.removeFromFavorites(movie.id);

        movie.isFavorite = false;

        _favorites.removeWhere(
          (m) => m.id == movie.id,
        );
      } else {
        await _dbService.addToFavorites(movie);

        movie.isFavorite = true;

        _favorites.add(movie);
      }
    } catch (e) {
      _errorMessage =
          'Failed to update favorites: $e';
    }
  }

  Future<void> fetchWatched() async {
    try {
      _watched =
          await _dbService.getWatched();

      for (var movie in _watched) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to load watched: $e';
    }
  }

  Future<void> markAsWatched(Movie movie) async {
    try {
      await _dbService.addToWatched(movie);

      movie.isWatched = true;
      movie.isWatching = false;
      movie.isWantToWatch = false;

      _watched =
          await _dbService.getWatched();

      _watching =
          await _dbService.getContinueWatching();

      for (var m in _watched) {
        m.isFavorite =
            await _dbService.isFavorite(m.id);
      }

      for (var m in _watching) {
        m.isFavorite =
            await _dbService.isFavorite(m.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to mark as watched: $e';
    }
  }

  Future<void> fetchWatching() async {
    try {
      _watching =
          await _dbService.getContinueWatching();

      for (var movie in _watching) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to load watching: $e';
    }
  }

  Future<void> startWatching(Movie movie) async {
    try {
      await _dbService.startWatching(movie);

      movie.isWatching = true;
      movie.isWatched = false;
      movie.isWantToWatch = false;

      _watching =
          await _dbService.getContinueWatching();

      for (var m in _watching) {
        m.isFavorite =
            await _dbService.isFavorite(m.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to start watching: $e';
    }
  }

  Future<void> fetchWantToWatch() async {
    try {
      _wantToWatch =
          await _dbService.getWantToWatch();

      for (var movie in _wantToWatch) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to load want to watch: $e';
    }
  }

  Future<void> addToWantToWatch(Movie movie) async {
    try {
      await _dbService.addToWantToWatch(movie);

      movie.isWantToWatch = true;
      movie.isWatched = false;
      movie.isWatching = false;

      _wantToWatch =
          await _dbService.getWantToWatch();

      for (var m in _wantToWatch) {
        m.isFavorite =
            await _dbService.isFavorite(m.id);
      }
    } catch (e) {
      _errorMessage =
          'Failed to add to want to watch: $e';
    }
  }

  Future<void> removeFromWantToWatch(
    Movie movie,
  ) async {
    try {
      await _dbService.removeFromWantToWatch(
        movie.id,
      );

      movie.isWantToWatch = false;

      _wantToWatch =
          await _dbService.getWantToWatch();
    } catch (e) {
      _errorMessage =
          'Failed to remove from want to watch: $e';
    }
  }

  Future<List<Movie>> searchMovies(
    String query,
  ) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final results =
          await _tmdbService.searchMovies(query);

      final filteredResults = results.where((movie) {
        return movie.genreIds.contains(16);
      }).toList();

      for (var movie in filteredResults) {
        movie.isFavorite =
            await _dbService.isFavorite(movie.id);

        movie.isWatched =
            await _dbService.isWatched(movie.id);

        movie.isWatching =
            await _dbService.isWatching(movie.id);

        movie.isWantToWatch =
            await _dbService.isWantToWatch(movie.id);
      }

      return filteredResults;
    } catch (e) {
      _errorMessage =
          'Failed to search: $e';

      return [];
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(
    int movieId,
  ) async {
    try {
      return await _tmdbService
          .getMovieDetails(movieId);
    } catch (e) {
      _errorMessage =
          'Failed to load movie details: $e';

      throw Exception(
        'Failed to load movie details',
      );
    }
  }

  void clearError() {
    _errorMessage = null;
  }
}
