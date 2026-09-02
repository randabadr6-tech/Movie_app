import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie_model.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _movieDetails;
  String? _errorMessage;

  static const Color backgroundColor = Color(0xFF08051F);
  static const Color primaryColor = Color(0xFF5B4BFF);
  static const Color fieldColor = Color(0xFF100C2C);

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<MovieProvider>();
      final details = await provider.getMovieDetails(widget.movie.id);

      if (!mounted) return;

      setState(() {
        _movieDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load movie details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildDetailsWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMovieDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsWidget() {
    final movie = widget.movie;

    String director = 'N/A';

    if (_movieDetails != null &&
        _movieDetails!['credits'] != null &&
        _movieDetails!['credits']['crew'] != null) {
      final crew = _movieDetails!['credits']['crew'] as List;

      final directors = crew.where(
        (person) => person['job'] == 'Director',
      );

      if (directors.isNotEmpty) {
        director = directors
            .map((person) => person['name'])
            .join(', ');
      }
    }

    List<dynamic> cast = [];

    if (_movieDetails != null &&
        _movieDetails!['credits'] != null &&
        _movieDetails!['credits']['cast'] != null) {
      cast = _movieDetails!['credits']['cast'] as List;

      if (cast.length > 10) {
        cast = cast.take(10).toList();
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                movie.backdropPath.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/original${movie.backdropPath}',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        cacheHeight: 400,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.movie,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (movie.releaseDate.isNotEmpty)
                        Text(
                          movie.releaseDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.2,
                            ),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: movie.posterPath.isNotEmpty
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                fit: BoxFit.cover,
                                cacheWidth: 200,
                                cacheHeight: 300,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return Container(
                                    color:
                                        Colors.grey.shade200,
                                    child:
                                        const Center(
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.deepPurple,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    color:
                                        Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color:
                                    Colors.grey.shade200,
                                child: const Icon(
                                  Icons.movie,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ 10',
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (!movie.isWatching &&
                              !movie.isWatched &&
                              !movie.isWantToWatch)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  final provider =
                                      context.read<
                                          MovieProvider>();

                                  provider.addToWantToWatch(
                                    movie,
                                  );

                                  setState(() {});

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        ' Added to Wishlist',
                                      ),
                                      backgroundColor:
                                          Colors.orange,
                                      duration:
                                          Duration(
                                        seconds: 1,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add to Wishlist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 14),

                          if (!movie.isWatching &&
                              !movie.isWatched)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  final provider =
                                      context.read<
                                          MovieProvider>();

                                  provider.startWatching(
                                    movie,
                                  );

                                  setState(() {});

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Added to Watching',
                                      ),
                                      backgroundColor:
                                          Colors.blue,
                                      duration:
                                          Duration(
                                        seconds: 1,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Start Watching',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      primaryColor,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 14),

                          if (!movie.isWatched)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child:
                                  OutlinedButton.icon(
                                onPressed: () {
                                  final provider =
                                      context.read<
                                          MovieProvider>();

                                  provider.markAsWatched(
                                    movie,
                                  );

                                  setState(() {});

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        ' Marked as Watched',
                                      ),
                                      backgroundColor:
                                          Colors.green,
                                      duration:
                                          Duration(
                                        seconds: 1,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Mark as Watched',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style:
                                    OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child:
                                OutlinedButton.icon(
                              onPressed: () {
                                final provider =
                                    context.read<
                                        MovieProvider>();

                                final wasFavorite =
                                    movie.isFavorite;

                                provider.toggleFavorite(
                                  movie,
                                );

                                setState(() {});

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wasFavorite
                                          ? '💔 Removed from favorites'
                                          : '❤️ Added to favorites',
                                    ),
                                    backgroundColor:
                                        wasFavorite
                                            ? Colors.orange
                                            : Colors.green,
                                    duration:
                                        const Duration(
                                      seconds: 1,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                movie.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: movie.isFavorite
                                    ? Colors.red
                                    : Colors.grey,
                                size: 18,
                              ),
                              label: Text(
                                movie.isFavorite
                                    ? 'Remove from Favorites'
                                    : 'Add to Favorites',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: movie.isFavorite
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                ),
                              ),
                              style:
                                  OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: movie.isFavorite
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (movie.isWantToWatch)
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.orange.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.bookmark,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Current Status: In Wishlist',
                                    style: TextStyle(
                                      color:
                                          Colors.orange,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (movie.isWatching &&
                              !movie.isWatched &&
                              !movie.isWantToWatch)
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.blue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Current Status: Watching',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (movie.isWatched)
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.green.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Current Status: Watched',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Story',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  movie.overview.isNotEmpty
                      ? movie.overview
                      : 'No story available for this movie',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 20),

                if (_movieDetails != null)
                  _buildMovieInformation(),

                const SizedBox(height: 20),

                if (_movieDetails != null &&
                    _movieDetails!['genres'] != null &&
                    (_movieDetails!['genres'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (_movieDetails!['genres'] as List)
                                .map((genre) {
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              genre['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                const Text(
                  'Director',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: primaryColor,
                        child: Icon(
                          Icons.movie_creation,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          director,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Cast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                if (cast.isEmpty)
                  Text(
                    'No cast information available',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  )
                else
                  Column(
                    children: cast.map((actor) {
                      final String name =
                          actor['name'] ?? 'Unknown';

                      final String character =
                          actor['character'] ?? '';

                      final String profilePath =
                          actor['profile_path'] ?? '';

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        padding:
                            const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),
                              child: profilePath.isNotEmpty
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w200$profilePath',
                                      width: 55,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 55,
                                          height: 70,
                                          color: Colors
                                              .grey
                                              .shade800,
                                          child:
                                              const Icon(
                                            Icons.person,
                                            color:
                                                Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 55,
                                      height: 70,
                                      color: Colors
                                          .grey.shade800,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  if (character.isNotEmpty)
                                    const SizedBox(height: 4),

                                  if (character.isNotEmpty)
                                    Text(
                                      'as $character',
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInformation() {
    final details = _movieDetails!;

    final int runtime = details['runtime'] ?? 0;

    final String releaseDate =
        details['release_date'] ?? '';

    final String originalLanguage =
        details['original_language'] ?? '';

    final String status =
        details['status'] ?? '';

    final int voteCount =
        details['vote_count'] ?? 0;

    final int budget =
        details['budget'] ?? 0;

    final int revenue =
        details['revenue'] ?? 0;

    String productionCompany = 'N/A';

    if (details['production_companies'] != null &&
        (details['production_companies'] as List).isNotEmpty) {
      final companies =
          details['production_companies'] as List;

      productionCompany = companies
          .map((company) => company['name'] ?? '')
          .where((name) => name.toString().isNotEmpty)
          .join(', ');

      if (productionCompany.isEmpty) {
        productionCompany = 'N/A';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Runtime',
          runtime > 0 ? '$runtime min' : 'N/A',
        ),

        _buildInfoRow(
          'Release Date',
          releaseDate.isNotEmpty
              ? releaseDate
              : 'N/A',
        ),

        _buildInfoRow(
          'Original Language',
          originalLanguage.isNotEmpty
              ? originalLanguage.toUpperCase()
              : 'N/A',
        ),

        _buildInfoRow(
          'Status',
          status.isNotEmpty
              ? status
              : 'N/A',
        ),

        _buildInfoRow(
          'Vote Count',
          voteCount > 0
              ? _formatNumber(voteCount)
              : 'N/A',
        ),

        _buildInfoRow(
          'Budget',
          budget > 0
              ? '\$${_formatNumber(budget)}'
              : 'N/A',
        ),

        _buildInfoRow(
          'Revenue',
          revenue > 0
              ? '\$${_formatNumber(revenue)}'
              : 'N/A',
        ),

        _buildInfoRow(
          'Production Company',
          productionCompany,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '$title : ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}