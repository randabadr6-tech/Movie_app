# Movix – Flutter Movie Application Documentation

## 1. Project Overview

**Movix** is a Flutter movie application focused on **Animation movies**. The application allows users to browse movies, search for movies, view detailed movie information, and manage their personal movie lists.

The application provides several movie states:

* Favorites
* Watched
* Continue Watching
* Wish List

The application also supports user authentication using **Firebase Authentication** and retrieves movie information from the **TMDB API**.

For local data storage, the application uses:

* **SharedPreferences** on the web.

The project follows a layered architecture that separates the user interface, business logic, and data sources.

---

# 2. Application Architecture

The main flow of the application is:

**UI → Provider → Controller → Service → Data Source**

For example, when the user wants to add a movie to Favorites:

**MovieDetailsScreen
↓
MovieProvider
↓
MovieController
↓
DatabaseService
↓
SharedPreferences

When retrieving movie data from TMDB:

**HomeScreen
↓
MovieProvider
↓
MovieController
↓
TmdbService
↓
TMDB API**

This separation makes the application easier to maintain, test, and organize.

---

# 3. Services Layer

The Services layer is responsible for communicating with external APIs, databases, Firebase, and device connectivity.

The main services are:

* TmdbService
* DatabaseService
* FirebaseService
* ConnectivityService

---

# 4. TmdbService

## Overview

`TmdbService` is responsible for communicating with the **TMDB API** and retrieving movie information.

Its main purpose is to separate API communication from the rest of the application.

## Main Responsibilities

TmdbService handles:

* Fetching Animation movies.
* Pagination.
* Searching for movies.
* Getting detailed information about a selected movie.
* Converting API JSON data into `Movie` objects.

## Pagination

The service uses variables such as:

* `_currentPage` – stores the current page number.
* `_totalPages` – stores the total number of pages returned by the API.
* `_hasMore` – determines whether additional pages are available.

### `getMovies()`

Starts retrieving movies from the first page.

### `loadMoreMovies()`

Loads the next page of movies.

The page number is increased and another API request is sent.

When the current page reaches the total number of available pages:

`_hasMore` becomes `false`.

This prevents the application from making unnecessary requests.

## API Response Handling

The API returns data in JSON format.

`json.decode()` converts the JSON response into a Dart `Map`.

The `results` list is then converted into a list of `Movie` objects using:

`Movie.fromJson()`

## Movie Details

`getMovieDetails()` retrieves additional information about a selected movie.

The request includes:

* Movie information.
* Videos.
* Credits.

This information is later used by the Movie Details Screen to display:

* Genres.
* Director.
* Cast.
* Other movie information.

## Search

`searchMovies()` sends the user's search query to TMDB and returns matching movies.

The MovieController later filters the results to keep Animation movies only.

---

# Database Service 

## 1. Overview

The `DatabaseService` is responsible for storing and retrieving movie data locally using **SharedPreferences**.

It manages the user's movie lists, including Favorites, Watched, Continue Watching, and Wish List.

## 2. SharedPreferences

SharedPreferences is used to store data locally on the device.

Since SharedPreferences stores simple data types, the `Movie` objects are converted to `Map` and then to a JSON string before being saved.

When the data is needed, the JSON string is decoded and converted back into `Movie` objects.

## 3. Saving and Reading Movies

The service uses two main private methods:

* `_saveMovies()` converts a `List<Movie>` into JSON and saves it using a specific key.
* `_getMovies()` reads the JSON stored under a key and converts it back into a `List<Movie>`.

The main storage keys are:

* `favorites`
* `watched`
* `continue_watching`
* `want_to_watch`

## 4. Favorites

The service can:

* Add a movie to Favorites.
* Remove a movie from Favorites.
* Get all favorite movies.
* Check whether a movie is a favorite.

Duplicate movies are removed before adding a movie.

## 5. Watched Movies

When a movie is marked as watched:

* It is removed from Wish List and Continue Watching.
* Its `isWatched` status becomes `true`.
* Its watching and wish list statuses become `false`.
* The current date and time are saved in `watchedDate`.

This keeps the movie status consistent.

## 6. Continue Watching

When the user starts watching a movie:

* It is removed from the Wish List.
* `isWatching` becomes `true`.
* `isWatched` and `isWantToWatch` become `false`.
* The start time is saved in `startWatchingDate`.
* The movie is stored in `continue_watching`.

Only movies that are currently being watched and are not marked as watched are returned by `getContinueWatching()`.

## 7. Wish List

The service can add and remove movies from the Wish List.

When a movie is added to the Wish List, it is removed from Watched and Continue Watching, and its status is updated using `isWantToWatch`.

The date is also stored in `wantToWatchDate`.

## 8. Data Clearing

`clearAllData()` removes all locally stored movie lists:

* Favorites
* Watched
* Continue Watching
* Wish List

It does not delete the user's Firebase account.


# 6. FirebaseService

## Overview

`FirebaseService` handles user authentication using **Firebase Authentication**.

It keeps authentication operations separate from the UI.

## Main Operations

### `signIn()`

Logs an existing user in using:

* Email
* Password

### `signUp()`

Creates a new account using email and password.

### `logout()`

Signs out the current user.

### `getCurrentUser()`

Returns the currently authenticated Firebase user.

### `userChanges`

Monitors authentication state changes.

This allows the application to know when a user logs in or logs out.

If login or signup fails, the operation returns `null`.

---

# 7. ConnectivityService

## Overview

`ConnectivityService` is responsible for checking and monitoring network connectivity.

## `hasInternet()`

Checks whether the device currently has an internet connection.

It returns:

* `true` if a connection is available.
* `false` if there is no connection.

## `connectivityStream`

Provides a stream that monitors connectivity changes such as:

* Wi-Fi
* Mobile data
* No connection

This keeps connectivity logic separate from the UI and authentication logic.

---

# 8. Controllers Layer

Controllers contain the main application logic.

The main controllers are:

* AuthController
* MovieController

They communicate with the appropriate services and prepare the data for the Providers and UI.

---

# 9. AuthController

## Overview

`AuthController` handles authentication logic.

It communicates with:

`FirebaseService`

## Main Variables

### `_user`

Stores the currently authenticated user.

### `_errorMessage`

Stores authentication errors.

### `isAuthenticated`

A getter that checks whether:

`_user != null`

If the user exists, the user is authenticated.

## `clearError()`

Clears the current authentication error.

## Authentication Flow

The flow is:

**UI
↓
AuthProvider
↓
AuthController
↓
FirebaseService
↓
Firebase Authentication**

---

# 10. AuthProvider

## Overview

`AuthProvider` connects `AuthController` with the UI using the Provider pattern.

It extends:

`ChangeNotifier`

## Responsibilities

AuthProvider exposes:

* Current user.
* Authentication state.
* Authentication errors.

It calls the AuthController for:

* Login.
* Signup.
* Logout.

After the authentication state changes, it calls:

`notifyListeners()`

This tells listening widgets that the state has changed and they should rebuild.

## Login and Signup

The login and signup methods return a `bool`.

* `true` → operation succeeded.
* `false` → operation failed.

---

# 11. MovieController

## Overview

`MovieController` manages the main movie-related business logic.

It connects:

* `TmdbService`
* `DatabaseService`

and prepares the required data for the UI.

## Main Responsibilities

MovieController manages:

* Movie lists.
* Loading states.
* Errors.
* Pagination.
* Search.
* Favorites.
* Watched movies.
* Continue Watching.
* Wish List.

## Fetching Movies

### `fetchMovies()`

Loads the first page of movies from TMDB.

After retrieving the movies, the controller checks the local database to determine whether each movie is:

* Favorite.
* Watched.
* Watching.
* In the Wish List.

This allows the UI to display the correct movie status.

## Pagination

### `loadMoreMovies()`

Loads additional pages from TMDB.

The new movies are added to the existing list using:

`addAll()`

The controller also:

* Prevents multiple loading operations at the same time.
* Checks whether more pages are available.

## Movie Lists

The controller manages:

* All movies.
* Favorites.
* Watched.
* Continue Watching.
* Wish List.

These lists are retrieved from the local database when needed.

## Movie Status

### `startWatching()`

Moves a movie to Continue Watching.

### `markAsWatched()`

Moves the movie from Continue Watching to Watched.

### `toggleFavorite()`

Checks whether the movie is already a favorite.

* If it is a favorite → remove it.
* If it is not → add it.

## Search

### `searchMovies()`

Searches TMDB using the user's query.

The results are filtered so that only Animation movies are returned.

The controller also checks the local database to determine each movie's current status.

## Movie Details

### `getMovieDetails()`

Retrieves detailed movie information from TMDB using the movie ID.

---

# 12. MovieProvider

## Overview

`MovieProvider` connects `MovieController` to the UI.

It uses:

`ChangeNotifier`

and the Provider package.

## Exposed Data

MovieProvider exposes:

* Movies.
* Favorites.
* Watched movies.
* Continue Watching.
* Wish List.
* Loading states.
* Error messages.

## Responsibility

The Provider does not contain the main business logic.

Instead, it delegates operations to:

`MovieController`

For example:

**UI requests favorite operation
↓
MovieProvider
↓
MovieController
↓
DatabaseService**

## `notifyListeners()`

After a state-changing operation, MovieProvider calls:

`notifyListeners()`

This causes widgets listening to the provider to rebuild and display the updated data.

## Search and Details

Search results and movie details can be returned directly because they do not necessarily need to be stored as persistent Provider state.

---

# 13. Model Layer

# Movie Model

## Overview

The `Movie` model represents movie data throughout the application.

It acts as the main data structure used between:

* TMDB API.
* Controllers.
* Providers.
* UI.
* Local database.

## JSON Conversion

### `fromJson()`

Converts API JSON data into a `Movie` object.

### `toJson()`

Converts a `Movie` object back into JSON.

## Movie Information

The model can contain information such as:

* Title.
* Overview.
* Poster path.
* Backdrop path.
* Release date.
* Runtime.
* Rating.
* Popularity.
* Genres.
* Production companies.
* Production countries.
* Cast.
* Crew.
* Videos.

## Movie Status

The model also stores the user's movie status:

* `isFavorite`
* `isWatched`
* `isWatching`
* `isWantToWatch`

It also contains related `DateTime` fields for storing when a movie was added to a particular state.


## Supporting Models

The Movie model works with additional models/classes such as:

* Genre
* Cast
* Crew
* Videos
* Video
* ProductionCompany
* ProductionCountry
* SpokenLanguage
* BelongsToCollection
* Credits

---

# 14. Widgets

# MovieGridItem

## Overview

`MovieGridItem` is a reusable widget responsible for displaying one movie inside a grid.

It extends:

`StatelessWidget`

because it does not manage its own internal state.

The required movie data and actions are passed to it from the parent widget.

## Main Properties

### `movie`

Contains the movie data to display.

### `onTap`

Called when the movie card is selected.

### `onFavoriteToggle`

Called when the user presses the favorite button.

## Movie Card

The card uses:

* `InkWell`
* `Card`

The card has rounded corners and a small elevation.

The parent widget determines what happens when the card is tapped.

## Poster

The poster is loaded using:

`Image.network()`

The URL is created using the TMDB image base URL together with the movie's `posterPath`.

If the poster does not exist, a movie icon is displayed.

While loading:

`CircularProgressIndicator`

is displayed.

If loading fails, a broken-image icon is shown.

## Image Performance

`cacheWidth` and `cacheHeight` are used to control the image size in memory and improve performance.

## Rating

The movie rating is displayed on the poster with a star icon.

The rating is formatted using:

`toStringAsFixed(1)`

For example:

`8.456 → 8.5`

## Movie Status

The widget displays the current movie status.

Possible states include:

* Wish List.
* Watched.
* Watching.

The Watching status is displayed only when:

`isWatching && !isWatched`

## Movie Information

Below the poster, the widget displays:

* Movie title.
* Release year.

The title is limited to one line.

`TextOverflow.ellipsis`

is used when the title is too long.

The release year is extracted from the release date.

For example:

`2024-05-10 → 2024`

## Favorite Button

The favorite button uses `IconButton`.

If the movie is a favorite:

`Icons.favorite`

is displayed.

Otherwise:

`Icons.favorite_border`

is displayed.

The actual favorite operation is handled by the parent through:

`onFavoriteToggle`

This keeps the widget reusable.

---

# 15. Screens

# HomeScreen

## Overview

`HomeScreen` is the main screen of Movix.

It allows the user to:

* Browse Animation movies.
* Search for movies.
* Open movie details.
* Access movie lists.
* Logout.

It uses:

* MovieProvider
* AuthProvider
* ConnectivityService

## Initialization

`initState()`:

* Checks internet connectivity.
* Adds a scroll listener for pagination.

## Connectivity Check

`_checkConnectivity()` uses `ConnectivityService`.

If there is no internet connection, the application displays a SnackBar informing the user.

If the internet is available, the screen requests movies through:

`MovieProvider.fetchMovies()`

## Pagination

`_handleScroll()` monitors the scroll position.

When the user gets close to the bottom of the movie list, it calls:

`loadMoreMovies()`

This allows additional movies to load automatically.

## AppBar

The AppBar contains:

* Movix logo.
* Profile.
* Wish List.
* Watched.
* Continue Watching.
* Favorites.
* Logout.

Navigation is performed using named routes or direct screen navigation depending on the destination.

## Search

The search field uses:

* `onChanged`
* `onSubmitted`

### `onChanged`

Search is performed when the text changes and is not empty.

### `onSubmitted`

Search is performed when the user submits the search field.

The search operation calls:

`MovieProvider.searchMovies()`

A loading indicator is shown while the search is running.

## Search Results

If search results are available, the screen displays:

* Result count.
* Movie grid.
* Clear search button.

If there are no results, it displays a message asking the user to try another search.

## Movie Grid

The main movie section displays Animation movies using:

`GridView`

Each movie is displayed using the reusable:

`MovieGridItem`

## Error Handling

If loading fails, the screen displays:

* Error icon.
* Error message.
* Retry button.

The Retry button clears the error and requests the movies again.

## Logout

Logout requires confirmation through a dialog.

After confirmation:

`AuthProvider.logout()`

is called.

The application then navigates to the Login Screen.

## Resource Management

The screen disposes of:

* `_searchController`
* `_scrollController`

using `dispose()`.

---

# 16. MovieDetailsScreen

## Overview

`MovieDetailsScreen` displays detailed information about the selected movie.

It receives a:

`Movie`

object from the previous screen.

It also retrieves additional information from TMDB, including:

* Genres.
* Director.
* Cast.
* Videos/credits information.

The screen is a `StatefulWidget` because its state changes while the screen is open.

## Initialization

`initState()` calls:

`_fetchMovieDetails()`

## Fetching Details

The screen uses:

`context.read<MovieProvider>()`

to access the provider without listening for rebuilds.

The flow is:

**MovieDetailsScreen
↓
MovieProvider
↓
MovieController
↓
TmdbService
↓
TMDB API**

After receiving the details, the screen updates its state.

`mounted` is checked before calling `setState()` after asynchronous operations to prevent lifecycle errors.

## Loading and Error States

While loading:

`CircularProgressIndicator`

is displayed.

If an error occurs, an error widget is displayed with a Retry button.

## SliverAppBar

The screen uses:

`CustomScrollView`

with:

* `SliverAppBar`
* `SliverList`

The AppBar expands and contains the movie backdrop.

The AppBar is pinned so it remains visible while scrolling.

## Backdrop

The backdrop is loaded from TMDB using the original image size.

If no image is available, a movie icon is displayed.

A gradient is placed over the image to make the movie title easier to read.

## Poster

The movie poster is displayed below the AppBar.

`ClipRRect`

is used to give the poster rounded corners.

## Rating

The rating is formatted using:

`toStringAsFixed(1)`

For example:

`8.456 → 8.5`

and displayed as:

`8.5 / 10`

## Movie Status Actions

The user can change the movie status.

### Add to Wish List

The movie is added using:

`provider.addToWantToWatch(movie)`

A SnackBar confirms the operation.

### Start Watching

The movie is moved to Continue Watching.

The local state is updated so that:

* `isWatching = true`
* `isWatched = false`
* `isWantToWatch = false`

### Mark as Watched

The movie is moved to Watched.

The state becomes:

* `isWatched = true`
* `isWatching = false`
* `isWantToWatch = false`

### Favorite

The user can add or remove the movie from Favorites through:

`provider.toggleFavorite(movie)`

The icon changes depending on the current favorite state.

## Current Status

The screen displays the current movie status:

* In Wishlist.
* Watching.
* Watched.

## Story

The movie overview is displayed as the story.

If no overview exists:

`No story available for this movie`

is displayed.

## Genres

Genres are extracted from the API response and displayed using styled containers inside a:

`Wrap`

## Director

The director is retrieved from:

`credits → crew`

The controller searches for the person whose job is:

`Director`

If no director is found:

`N/A`

is displayed.

## Cast

The cast is retrieved from:

`credits → cast`

The screen displays up to the first 10 actors.

For every actor, the UI can show:

* Actor name.
* Character name.
* Profile image.

If an actor image is unavailable, a person icon is displayed.

---

# 17. FavoritesScreen

## Overview

`FavoritesScreen` displays all movies marked as Favorites.

The user can:

* View favorite movies.
* Refresh the list.
* Open movie details.
* Remove favorites.
* Return to Home if the list is empty.

The screen is a `StatefulWidget` because its displayed data can change.

## Loading Favorites

When the screen opens, it requests:

`provider.fetchFavorites()`

This is called after the first frame using:

`WidgetsBinding.instance.addPostFrameCallback`

The flow is:

**FavoritesScreen
↓
MovieProvider
↓
MovieController
↓
DatabaseService
↓
Database**

## Consumer

`Consumer<MovieProvider>` listens for changes.

When the provider calls:

`notifyListeners()`

the screen rebuilds with the latest data.

## States

The screen handles four main states:

### Loading

Displays:

* Progress indicator.
* Loading message.

### Error

Displays:

* Error icon.
* Error message.
* Retry button.

### Empty

Displays:

* Heart icon.
* No favorites message.
* Explanation.
* Go to Home button.

### Available Movies

Displays the favorite movies in a two-column grid.

## Movie Count

The number of favorite movies is displayed using:

`provider.favorites.length`

## Movie Details

Selecting a movie opens:

`MovieDetailsScreen`

When the user returns, the Favorites list is fetched again so that any changed movie status is reflected.

## Favorite Toggle

The user can remove a movie using:

`provider.toggleFavorite(movie)`

---

# 18. WishlistScreen

## Overview

`WishlistScreen` displays movies that the user wants to watch later.

It retrieves the Wish List through:

`MovieProvider`

## Initialization

`initState()` runs once and requests the wishlist after the first frame.

This is done using:

`addPostFrameCallback`

## Refresh

The AppBar contains a refresh button that reloads the wishlist.

A SnackBar informs the user that the list is being refreshed.

## Provider Communication

The screen uses:

`Consumer<MovieProvider>`

so changes in the provider automatically update the UI.

## States

The screen handles:

* Loading.
* Error.
* Empty.
* Available movies.

## Empty State

If there are no movies, the screen displays:

* Wishlist icon.
* Explanation.
* Go to Home button.

## Grid

The movies are displayed using:

`GridView.builder`

This is useful because it:

* Dynamically handles the number of items.
* Avoids repeated UI code.
* Builds items efficiently.

Each item uses the reusable:

`MovieGridItem`

## Navigation

Selecting a movie opens:

`MovieDetailsScreen`

After returning, the wishlist is fetched again to reflect any changes.

---

# 19. ContinueWatchingScreen

## Overview

The Continue Watching Screen displays movies that the user has already started watching.

Its main purpose is to allow users to continue watching without searching for the movie again.

## Loading

When the screen opens, it calls:

`fetchWatching()`

through MovieProvider after the first frame.

## States

The screen handles:

* Loading.
* Error.
* Empty.
* Available movies.

## Available Movies

Movies are displayed in a grid using:

`MovieGridItem`

The number of movies is also displayed.

## Movie Details

Selecting a movie opens:

`MovieDetailsScreen`

When the user returns, the list is fetched again because the movie status may have changed.

## Refresh

The AppBar refresh button calls:

`fetchWatching()`

and displays a SnackBar.

## Favorites

The favorite state can be changed through:

`provider.toggleFavorite(movie)`

---

# 20. WatchedScreen

## Overview

The Watched Screen displays movies that have been marked as watched.

## Loading

When the screen opens:

`fetchWatched()`

is called through MovieProvider.

## States

The screen handles:

* Loading.
* Error.
* Empty.
* Available movies.

## Grid

Available movies are displayed using:

`GridView`

and the reusable:

`MovieGridItem`

## Details

Selecting a movie opens:

`MovieDetailsScreen`

When the user returns, the watched list is reloaded.

## Refresh

The AppBar refresh button calls:

`fetchWatched()`

## Favorites

The user can change a movie's favorite state using:

`provider.toggleFavorite(movie)`

---

# 21. LoginScreen

## Overview

`LoginScreen` allows existing users to log into Movix using:

* Email.
* Password.

It communicates with:

`AuthProvider`

After successful authentication, it uses:

`MovieProvider`

to load the movie data.

## UI Components

The screen contains:

* Email field.
* Password field.
* Password visibility button.
* Login button.
* Signup link.

## Login Flow

When the user presses Login:

1. The email is retrieved from the email controller.
2. The password is retrieved from the password controller.
3. The credentials are passed to AuthProvider.
4. AuthProvider communicates with AuthController.
5. AuthController communicates with FirebaseService.
6. Firebase Authentication verifies the credentials.

If login succeeds:

`fetchMovies()`

is called.

Then the application navigates to Home.

## Loading

While login is running:

* A loading indicator is displayed.
* The Login button is disabled.

## Error Handling

If login fails, an error message is displayed.

## Password Visibility

`_obscurePassword` controls whether the password is hidden or visible.

## Navigation

The Signup link opens SignupScreen.

After successful login, the application uses:

`Navigator.pushReplacement`

to open Home.

This prevents the user from returning to the Login Screen using the Back button.

## Resource Management

The screen disposes of its:

`TextEditingController`

objects using `dispose()`.

---

# 22. SignupScreen

## Overview

`SignupScreen` allows a new user to create an account using email and password.

It uses:

`AuthProvider`

## UI Components

The screen contains:

* Email field.
* Password field.
* Confirm Password field.
* Password visibility controls.
* Create Account button.
* Login link.

## Signup Flow

When the user submits the form:

1. The password is retrieved.
2. The confirmation password is retrieved.
3. Both passwords are compared.
4. If they do not match, an error is displayed and the process stops.
5. If they match, the data is sent to AuthProvider.
6. AuthProvider communicates with AuthController.
7. AuthController communicates with FirebaseService.
8. Firebase creates the new account.

## Loading

While registration is in progress:

* Loading indicator is displayed.
* Create Account button is disabled.

## Error Handling

If registration fails, an error message is displayed.

## Successful Registration

After successful registration, a success message is displayed and the user is taken to the Login Screen.

## Navigation

Existing users can select Login to return to the Login Screen.

## Resource Management

All `TextEditingController` objects are disposed of using `dispose()`.

---

# 23. ProfileScreen

## Overview

`ProfileScreen` displays the current user's information and provides access to the user's movie lists.

## User Information

The screen uses:

`context.watch<AuthProvider>()`

to listen to authentication changes.

The user's email is displayed.

The first part of the email can be used as the displayed username.

## Movie Lists

The Profile Screen provides access to:

* My Favorites.
* Watched.
* Continue Watching.
* Wish List.

A reusable `_buildMenuItem()` method is used to avoid repeating the same UI structure.

## Navigation

The screen uses named routes through:

`Navigator.pushNamed()`

to navigate to the different movie-list screens.

## Logout

The screen provides Logout functionality.

Before logging out, `_showLogoutDialog()` displays a confirmation dialog.

If the user confirms:

1. `AuthProvider.logout()` is called.
2. Firebase signs the user out.
3. The application navigates to Login using:
   `pushReplacementNamed()`

This prevents the user from returning to the authenticated screen using Back.

## `watch` vs `read`

`context.watch<AuthProvider>()` is used when the screen needs to react to changes in the authentication state.

`context.read<AuthProvider>()` is used for operations such as logout when rebuilding the widget is not required.

---

# 24. Main.dart

## Overview

`main.dart` is the entry point of the Movix application.

It is responsible for:

* Initializing Firebase.
* Setting up Providers.
* Configuring the application.
* Managing routes.
* Selecting the initial screen based on authentication state.

---

## Firebase Initialization

Before starting the application, Firebase is initialized using:

`Firebase.initializeApp()`

This allows Movix to use Firebase services, especially:

**Firebase Authentication**

---

## MultiProvider

The application uses:

`MultiProvider`

to provide the main application providers.

### AuthProvider

Responsible for:

* Login.
* Signup.
* Logout.
* Current user.
* Authentication state.

### MovieProvider

Responsible for:

* Movies.
* Favorites.
* Watched movies.
* Continue Watching.
* Wish List.
* Movie-related loading and error states.

These providers become available to the application's screens.

---

# 25. MaterialApp

`MaterialApp` defines the main configuration of the application.

It sets:

* Application title.
* Theme.
* Material 3 support.
* Debug banner visibility.
* Initial route.
* Named routes.

---

# 26. Authentication Check

The `/` route uses:

`Consumer<AuthProvider>`

to check the current authentication state.

If:

`isAuthenticated == true`

the application displays:

**Home Screen**

If:

`isAuthenticated == false`

the application displays:

**Login Screen**

This allows Movix to automatically select the correct starting screen depending on whether the user is authenticated.

---

# 27. Named Routes

The application defines named routes for the main screens.

These include:

* `/login`
* `/signup`
* `/home`
* `/favorites`
* `/watched`
* `/continueWatching`
* `/wishlist`
* `/profile`

Named routes make navigation more organized and easier to manage.

---

# 28. Movie Details Route

The Movie Details Screen requires a `Movie` object.

Because the selected movie needs to be passed to the screen, the application uses:

`onGenerateRoute`

The selected movie is passed through:

`settings.arguments`

and then used to create:

`MovieDetailsScreen`

This allows the application to open the details page for the exact movie selected by the user.

---

# 29. Web Index – index.html

## Overview

`index.html` is the main HTML entry point for the Flutter Web version of Movix.

It provides:

* HTML structure.
* CSS styling.
* Firebase Web SDK initialization.
* Splash screen.
* Flutter application loading.

---

# 30. Splash Screen

The splash screen appears while the Flutter application is loading.

It contains:

* Movix logo.
* Application name.
* Subtitle.
* Animated particles.
* Loading dots.
* Progress bar.

The splash screen provides a loading experience before the Flutter UI becomes available.

## CSS Animations

The splash screen uses CSS animations for elements such as:

* Floating logo.
* Glow effects.
* Expanding rings.
* Moving particles.
* Bouncing loading dots.
* Progress bar.

---

# 31. Firebase Web Initialization

The Firebase JavaScript SDK is loaded in `index.html`.

A `firebaseConfig` object contains the Firebase project configuration.

Firebase is initialized using:

`firebase.initializeApp()`

This allows the Flutter Web application to use Firebase services.

---

# 32. Flutter Web Loading

The compiled Flutter application is loaded through:

`main.dart.js`

This is the compiled JavaScript version of the Dart/Flutter application.

Once loaded, it starts the Flutter application inside the browser.

---

# 33. Splash Screen Controller

JavaScript dynamically creates background particles.

`Math.random()` is used to give particles different:

* Positions.
* Sizes.
* Animation durations.
* Animation delays.

After the page finishes loading, the splash screen remains visible briefly and then receives the `hide` class.

This creates a smooth fade-out transition before displaying the Flutter application.

---

# 34. Complete Application Data Flow

## Authentication Flow

When the user logs in:

**LoginScreen
↓
AuthProvider
↓
AuthController
↓
FirebaseService
↓
Firebase Authentication**

After successful authentication:

**MovieProvider
↓
MovieController
↓
TmdbService
↓
TMDB API**

The movies are then displayed on HomeScreen.

---

# 35. Fetch Movies Flow

When HomeScreen loads:

**HomeScreen
↓
MovieProvider.fetchMovies()
↓
MovieController.fetchMovies()
↓
TmdbService
↓
TMDB API**

The returned JSON is converted into Movie objects.

The controller then checks the local database for the user's movie statuses.

Finally:

**MovieController
↓
MovieProvider
↓
notifyListeners()
↓
HomeScreen**

The UI displays the updated movies.

---

# 36. Search Flow

When the user searches for a movie:

**HomeScreen
↓
MovieProvider.searchMovies()
↓
MovieController.searchMovies()
↓
TmdbService.searchMovies()
↓
TMDB API**

The returned movies are filtered to Animation movies.

The results are then returned to HomeScreen and displayed using `MovieGridItem`.

---

# 37. Movie Details Flow

When the user selects a movie:

**MovieGridItem
↓
MovieDetailsScreen
↓
MovieProvider
↓
MovieController
↓
TmdbService
↓
TMDB API**

The screen receives the movie's additional information and displays:

* Poster.
* Backdrop.
* Rating.
* Story.
* Genres.
* Director.
* Cast.
* Movie status.

---

# 38. Favorite Flow

When the user presses the Favorite button:

**MovieGridItem / MovieDetailsScreen
↓
MovieProvider.toggleFavorite()
↓
MovieController.toggleFavorite()
↓
DatabaseService
↓
SharedPreferences

After the database is updated:

**MovieController
↓
MovieProvider
↓
notifyListeners()
↓
UI rebuilds**

---

# 39. Watch Status Flow

When the user starts watching:

**MovieDetailsScreen
↓
MovieProvider.startWatching()
↓
MovieController.startWatching()
↓
DatabaseService
↓
Continue Watching**

When the movie is marked as watched:

**MovieDetailsScreen
↓
MovieProvider.markAsWatched()
↓
MovieController.markAsWatched()
↓
DatabaseService
↓
Watched**

This keeps the user's movie lists synchronized.

---

# 40. Logout Flow

When the user chooses Logout:

**ProfileScreen / HomeScreen
↓
AuthProvider.logout()
↓
AuthController
↓
FirebaseService
↓
Firebase Authentication**

After logout:

**Navigator.pushReplacementNamed('/login')**

The user is returned to the Login Screen and cannot return to the authenticated screens using the Back button.

---

# 41. Overall Project Structure

The main structure of the project can be understood as:

```text
Movix
│
├── main.dart
│
├── models
│   └── movie_model.dart
│
├── services
│   ├── tmdb_service.dart
│   ├── database_service.dart
│   ├── firebase_service.dart
│   └── connectivity_service.dart
│
├── controllers
│   ├── movie_controller.dart
│   └── auth_controller.dart
│
├── providers
│   ├── movie_provider.dart
│   └── auth_provider.dart
│
├── screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── movie_details_screen.dart
│   ├── favorites_screen.dart
│   ├── wishlist_screen.dart
│   ├── continue_watching_screen.dart
│   ├── watched_screen.dart
│   └── profile_screen.dart
│
└── widgets
    └── movie_grid_item.dart
```

---

# 42. Technologies Used

The main technologies and packages used in Movix include:

* **Flutter** – application development.
* **Dart** – programming language.
* **Provider** – state management.
* **Firebase Authentication** – user authentication.
* **TMDB API** – movie data.
* **SharedPreferences** – local storage on Web.
* **Material 3** – application UI.
* **Navigator / Named Routes** – screen navigation.

---

# 43. Final Summary

Movix is structured using a layered architecture that separates the responsibilities of the application.

The **UI layer** is responsible for displaying information and receiving user interactions.

The **Provider layer** connects the UI with the application's logic and uses `ChangeNotifier` to update the UI when data changes.

The **Controller layer** contains the main business logic and communicates with the required services.

The **Service layer** handles external and local data sources such as:

* TMDB API.
* Firebase Authentication.
* SharedPreferences.
* Network connectivity.

The **Model layer** defines the structure of movie data and handles conversion between API, application objects, and local database data.

The overall architecture can therefore be summarized as:

**UI
↓
Provider
↓
Controller
↓
Service
↓
API / Database / Firebase**

This structure makes Movix more organized, maintainable, reusable, and easier to expand with additional features in the future.