import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _authController = AuthController();

  bool get isAuthenticated => _authController.isAuthenticated;
  String? get errorMessage => _authController.errorMessage;
  User? get user => _authController.user;

  // LOGIN

  Future<bool> login(String email, String password) async {
    final user = await _authController.login(email, password);
    notifyListeners();  
    return user != null;
  }

  // SIGN UP
  
  Future<bool> signUp(String email, String password) async {
    final user = await _authController.signUp(email, password);
    notifyListeners();
    return user != null;
  }

  // LOGOUT

  Future<void> logout() async {
    await _authController.logout();
    notifyListeners();
  }

  // CLEAR ERROR

  void clearError() {
    _authController.clearError();
    notifyListeners();
  }
}