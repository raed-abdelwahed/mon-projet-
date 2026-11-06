// lib/services/auth_service.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/utilisateur.dart';
import 'database_service.dart';

/// Erreur lisible renvoyée à l'écran (ex : email déjà utilisé).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

/// Connexion, inscription et recherche d'utilisateurs.
class AuthService {
  /// Hache le mot de passe : on ne stocke jamais un mot de passe en clair.
  static String hacher(String motDePasse) =>
      sha256.convert(utf8.encode(motDePasse)).toString();

  Future<Utilisateur?> connecter(String email, String motDePasse) async {
    final db = await DatabaseService.instance.database;
    final resultat = await db.query(
      'utilisateurs',
      where: 'email = ? AND mot_de_passe = ?',
      whereArgs: [email.trim().toLowerCase(), hacher(motDePasse)],
      limit: 1,
    );
    return resultat.isEmpty ? null : Utilisateur.fromMap(resultat.first);
  }

  Future<Utilisateur> inscrire({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    final db = await DatabaseService.instance.database;
    final emailPropre = email.trim().toLowerCase();

    final existe = await db.query(
      'utilisateurs',
      where: 'email = ?',
      whereArgs: [emailPropre],
    );
    if (existe.isNotEmpty) {
      throw AuthException('Cet email est déjà utilisé.');
    }

    final nouveau = Utilisateur(
      nom: nom.trim(),
      email: emailPropre,
      motDePasse: hacher(motDePasse),
      role: 'client', // une inscription crée toujours un client
    );
    final id = await db.insert('utilisateurs', nouveau.toMap()..remove('id'));

    return Utilisateur(
      id: id,
      nom: nouveau.nom,
      email: nouveau.email,
      motDePasse: nouveau.motDePasse,
      role: nouveau.role,
    );
  }

  Future<Utilisateur?> trouverParId(int id) async {
    final db = await DatabaseService.instance.database;
    final resultat = await db.query(
      'utilisateurs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return resultat.isEmpty ? null : Utilisateur.fromMap(resultat.first);
  }
}
