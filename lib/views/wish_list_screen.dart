import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_grid_item.dart';
import 'movie_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  static const Color backgroundColor = Color(0xFF08051F);
  static const Color primaryColor = Color(0xFF5B4BFF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchWantToWatch();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          '📋 Wish List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<MovieProvider>().fetchWantToWatch();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Refreshing...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.fetchWantToWatch();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (provider.wantToWatch.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add, size: 100, color: Colors.grey.shade600),
                  const SizedBox(height: 24),
                  Text(
                    'No movies in your wishlist',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add movies you want to watch later',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Home', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                child: Text(
                  '${provider.wantToWatch.length} movies',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: provider.wantToWatch.length,
                  itemBuilder: (context, index) {
                    final movie = provider.wantToWatch[index];
                    return MovieGridItem(
                      movie: movie,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movie: movie),
                          ),
                        ).then((_) {
                          if (mounted) {
                            provider.fetchWantToWatch();
                          }
                        });
                      },
                      onFavoriteToggle: () {
                        provider.toggleFavorite(movie);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}