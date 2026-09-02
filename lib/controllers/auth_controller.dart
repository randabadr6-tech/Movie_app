
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthController {
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  // LOGIN

  Future<User?> login(
    String email,
    String password,
  ) async {
    _errorMessage = null;

    try {
      final user = await _firebaseService.signIn(
        email,
        password,
      );

      if (user != null) {
        _user = user;
      }

      return user;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      return null;
    }
  }

  // SIGN UP

  Future<User?> signUp(
    String email,
    String password,
  ) async {
    _errorMessage = null;

    try {
      final user = await _firebaseService.signUp(
        email,
        password,
      );

      if (user != null) {
        _user = user;
      }

      return user;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      return null;
    }
  }
  // LOGOUT

  Future<void> logout() async {
    try {
      await _firebaseService.logout();

      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');
    }
  }

  void clearError() {
    _errorMessage = null;
  }
}

