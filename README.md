# Movix - Movie App

A Flutter movie application developed as a graduation project for the ITI Summer Internship 2026. The app provides a complete movie browsing experience with authentication, API calling, local storage, and state management.

---

## Features

### Authentication
- User registration with email and password
- User login with email and password
- User logout
- Error handling for authentication failures

### Movie Browsing
- Display animation movies fetched from TMDB API
- Movie grid layout with posters and ratings
- Infinite scroll with pagination (Load More)
- Movie details screen with:
  - Backdrop and poster images
  - Title, release year, and rating
  - Story overview
  - Genres
  - Director name
  - Cast list
  - Runtime

### Search
- Local search functionality across loaded movies
- Real-time filtering by movie title

### Favorites
- Add/remove movies to/from favorites
- Persistent storage using shared prefrence
- Favorites screen to view all saved movies

### Movie Lists (Three States)
- **Watched**: Movies the user has already watched
- **Currently Watching**: Movies in progress
- **Wishlist**: Movies the user plans to watch later

### Profile
- Display user email and name
- Quick navigation to all movie lists
- Logout functionality

### Additional Features
- Splash screen with loading animation
- Error handling (network errors, empty states, loading indicators)

---

## Backend Services

- **Firebase Authentication**: User authentication (Email/Password)
- **TMDB API**: Movie data

## Local Storage

- **Shared prefrence**: Favorites, movie lists

## State Management

- **Provider**: Managing application state across different screens

## Utilities

- **Connectivity Plus**: Network connectivity checking
- **Cached Network Image**: Image caching

---

## Architecture

The project follows the **MVC (Model-View-Controller)** architecture pattern:

### Models
- `movie_model.dart`: Movie data structure with JSON serialization

### Views
- All UI screens in `views/` folder
- Reusable components in `widgets/` folder

### Controllers
- `auth_controller.dart`: Authentication logic
- `movie_controller.dart`: Movie data and operations

### Providers
- `auth_provider.dart`: Authentication state management
- `movie_provider.dart`: Movie state management

### Services
- `firebase_service.dart`: Firebase operations
- `tmdb_service.dart`: TMDB API integration
- `database_service.dart`: shared prefrence