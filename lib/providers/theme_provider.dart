// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le thème clair / sombre et le mémorise entre deux lancements.
class ThemeProvider extends ChangeNotifier {
  static const String _cle = 'theme_sombre';

  bool _estSombre = false;

  bool get estSombre => _estSombre;

  ThemeMode get modeTheme => _estSombre ? ThemeMode.dark : ThemeMode.light;

  /// Lit le choix enregistré au démarrage de l'application.
  Future<void> chargerTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _estSombre = prefs.getBool(_cle) ?? false;
    notifyListeners();
  }

  /// Passe du clair au sombre (ou l'inverse) et enregistre le choix.
  Future<void> basculerTheme() async {
    _estSombre = !_estSombre;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cle, _estSombre);
  }
}
