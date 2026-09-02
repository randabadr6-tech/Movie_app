
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/connectivity_service.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../models/movie_model.dart';
import '../widgets/movie_grid_item.dart';

import 'favorites_screen.dart';
import 'watched_screen.dart';
import 'continue_watching_screen.dart';
import 'wish_list_screen.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Movie> _searchResults = [];

  bool _isSearching = false;
  bool _showResults = false;


  static const Color backgroundColor = Color(0xFF08051F);
  static const Color primaryColor = Color(0xFF5B4BFF);
  static const Color fieldColor = Color(0xFF100C2C);

  @override
  void initState() {
    super.initState();

    _checkConnectivity();

    _scrollController.addListener(_handleScroll);
  }

  Future<void> _checkConnectivity() async {
    final service = ConnectivityService();

    final hasInternet = await service.hasInternet();

    if (!mounted) return;

    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No internet connection'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MovieProvider>().fetchMovies();
        }
      });
    }
  }
  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll < 300) {
      context.read<MovieProvider>().loadMoreMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

    
appBar: AppBar(
  backgroundColor: backgroundColor,
  foregroundColor: Colors.white,
  elevation: 0,

  titleSpacing: 8,

  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          height: 30,
          width: 30,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.movie,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      ),

      const SizedBox(width: 8),

      const Text(
        'Movix',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),

  actions: [
    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.person,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/profile');
      },
    ),

    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.bookmark_border,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WishlistScreen(),
          ),
        );
      },
    ),

    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.visibility,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WatchedScreen(),
          ),
        );
      },
    ),

    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.play_circle,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContinueWatchingScreen(),
          ),
        );
      },
    ),

    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.favorite,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FavoritesScreen(),
          ),
        );
      },
    ),

    IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      onPressed: _logout,
    ),
  ],
),



      body: Padding(
        padding: const EdgeInsets.only(top: 8),

        child: Column(
          children: [
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              child: Container(
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),

                      child: Icon(
                        Icons.search,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: TextField(
                        controller: _searchController,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: InputDecoration(
                          hintText: 'Search for movies...',

                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),

                          border: InputBorder.none,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),

                        onChanged: (value) {
                          if (value.trim().isNotEmpty) {
                            _performSearch(value);
                          } else {
                            setState(() {
                              _searchResults = [];
                              _showResults = false;
                              _isSearching = false;
                            });
                          }
                        },

                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _performSearch(value);
                          }
                        },
                      ),
                    ),

                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 20,
                        ),

                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchResults = [];
                            _showResults = false;
                            _isSearching = false;
                          });
                        },
                      ),


                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),

                        child: SizedBox(
                          width: 18,
                          height: 18,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_showResults)
              _buildSearchResults(),


            if (!_showResults)
              _buildMovies(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
  
    if (_searchResults.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                Icons.search_off,
                size: 50,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 8),

              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Try searching for something else',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Results (${_searchResults.length})',

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                TextButton(
                  onPressed: _clearSearch,

                  child: const Text(
                    'Close',

                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(6),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),

              itemCount: _searchResults.length,

              itemBuilder: (context, index) {
                final movie = _searchResults[index];

                return MovieGridItem(
                  movie: movie,

                  onTap: () {
                    _clearSearch();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(
                          movie: movie,
                        ),
                      ),
                    );
                  },

                  onFavoriteToggle: () {
                    context
                        .read<MovieProvider>()
                        .toggleFavorite(movie);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovies() {
    return Expanded(
      child: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          // =========================
          // Initial Loading
          // =========================

          if (provider.isLoading &&
              provider.movies.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (provider.errorMessage != null) {
            return _buildError(provider);
          }

          if (provider.movies.isEmpty) {
            return const Center(
              child: Text(
                'No movies available',

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            children: [
            
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.local_movies,
                      color: primaryColor,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Animation Movies',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${provider.movies.length} movies',

                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  controller: _scrollController,

                  padding: const EdgeInsets.all(6),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),

                  itemCount: provider.movies.length,

                  itemBuilder: (context, index) {
                    final movie = provider.movies[index];

                    return MovieGridItem(
                      movie: movie,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailsScreen(
                              movie: movie,
                            ),
                          ),
                        );
                      },


                      onFavoriteToggle: () {
                        provider.toggleFavorite(movie);
                      },
                    );
                  },
                ),
              ),

              if (provider.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError(MovieProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red.shade300,
          ),

          const SizedBox(height: 12),

          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.fetchMovies();
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),

            child: const Text(
              'Retry',

              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final provider = context.read<MovieProvider>();

      final results =
          await provider.searchMovies(query.trim());

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchResults = [];
      _showResults = false;
      _isSearching = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          actions: [
           
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}

