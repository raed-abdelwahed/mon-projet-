// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/utilisateur.dart';
import '../services/auth_service.dart';

/// Garde l'utilisateur connecté et sa session (même après redémarrage).
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  static const String _cleSession = 'utilisateur_id';

  Utilisateur? _utilisateur;

  Utilisateur? get utilisateur => _utilisateur;
  bool get estConnecte => _utilisateur != null;
  bool get estAdmin => _utilisateur?.estAdmin ?? false;

  /// Au démarrage : reconnecte automatiquement le dernier utilisateur.
  Future<void> initialiser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_cleSession);
    if (id != null) {
      _utilisateur = await _service.trouverParId(id);
    }
    notifyListeners();
  }

  /// Renvoie null si tout va bien, sinon un message d'erreur.
  Future<String?> connecter(String email, String motDePasse) async {
    final utilisateur = await _service.connecter(email, motDePasse);
    if (utilisateur == null) return 'Email ou mot de passe incorrect.';
    await _ouvrirSession(utilisateur);
    return null;
  }

  Future<String?> inscrire({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    try {
      final utilisateur = await _service.inscrire(
        nom: nom,
        email: email,
        motDePasse: motDePasse,
      );
      await _ouvrirSession(utilisateur);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> deconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cleSession);
    _utilisateur = null;
    notifyListeners();
  }

  Future<void> _ouvrirSession(Utilisateur utilisateur) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cleSession, utilisateur.id!);
    _utilisateur = utilisateur;
    notifyListeners();
  }
}
