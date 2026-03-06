import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> init() async {
    _user = await _service.getCurrentUser();
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      _user = await _service.login(email, password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      _user = await _service.register(name, email, password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères min)';
      case 'invalid-email':
        return 'Email invalide';
      default:
        return 'Erreur : $code';
    }
  }
}
