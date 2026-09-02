import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'models/movie_model.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'views/home_screen.dart';
import 'views/favorites_screen.dart';
import 'views/watched_screen.dart';
import 'views/continue_watching_screen.dart';
import 'views/wish_list_screen.dart';
import 'views/movie_details_screen.dart';
import 'views/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBdP5uvBNl6Db23NYtgrzm9k3ROaozpqeU',
      appId: '1:235594362366:web:00b2aed136b340daea64af',
      messagingSenderId: '235594362366',
      projectId: 'movie-app-9d2be',
      authDomain: 'movie-app-9d2be.firebaseapp.com',
      storageBucket: 'movie-app-9d2be.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'Movix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/watched': (context) => const WatchedScreen(),
          '/continue_watching': (context) => const ContinueWatchingScreen(),
          '/want_to_watch': (context) => const WishlistScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/movie_details') {
            final movie = settings.arguments as Movie;
            return MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movie: movie),
            );
          }
          return null;
        },
      ),
    );
  }
}