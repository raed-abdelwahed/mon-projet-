// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';

import 'auth_service.dart';
import 'db_factory.dart';

/// Ouvre la base SQLite, crée les tables et insère les données de départ.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String _nomBase = 'sup4_ecommerce.db';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    configurerFactory();
    _db = await openDatabase(_nomBase, version: 1, onCreate: _creerTables);
    return _db!;
  }

  Future<void> _creerTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utilisateurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        mot_de_passe TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'client'
      )
    ''');
    await db.execute('''
      CREATE TABLE produits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT,
        prix REAL NOT NULL,
        prix_promo REAL,
        stock INTEGER NOT NULL DEFAULT 0,
        categorie TEXT NOT NULL,
        vedette INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE coupons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        pourcentage INTEGER NOT NULL,
        actif INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE commandes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        sous_total REAL NOT NULL,
        remise REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        statut TEXT NOT NULL,
        code_coupon TEXT,
        adresse TEXT NOT NULL,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE lignes_commande (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        nom_produit TEXT NOT NULL,
        prix_unitaire REAL NOT NULL,
        quantite INTEGER NOT NULL,
        FOREIGN KEY (commande_id) REFERENCES commandes(id)
      )
    ''');
    await _insererDonneesInitiales(db);
  }

  /// Comptes de test, produits et coupons pour avoir une boutique remplie.
  Future<void> _insererDonneesInitiales(Database db) async {
    final batch = db.batch();

    // --- Comptes ---
    batch.insert('utilisateurs', {
      'nom': 'Administrateur',
      'email': 'admin@sup4.tn',
      'mot_de_passe': AuthService.hacher('admin123'),
      'role': 'admin',
    });
    batch.insert('utilisateurs', {
      'nom': 'Client Démo',
      'email': 'client@sup4.tn',
      'mot_de_passe': AuthService.hacher('client123'),
      'role': 'client',
    });

    // --- Produits ---
    final produits = [
      ['Écouteurs sans fil', 'Écouteurs Bluetooth 5.3 avec réduction de bruit et 24 h d\'autonomie.', 129.0, 99.0, 25, 'Électronique', 1],
      ['Montre connectée', 'Suivi du sommeil, du rythme cardiaque et notifications du téléphone.', 249.0, null, 10, 'Électronique', 1],
      ['Clavier mécanique RGB', 'Clavier gamer avec switches rouges et rétroéclairage personnalisable.', 189.0, null, 15, 'Électronique', 0],
      ['T-shirt coton bio', 'T-shirt 100 % coton biologique, coupe classique, plusieurs tailles.', 35.0, 25.0, 50, 'Mode', 0],
      ['Sneakers urbaines', 'Baskets légères et confortables pour un usage quotidien.', 159.0, null, 20, 'Mode', 1],
      ['Lampe de bureau LED', 'Lampe à intensité réglable avec port USB de recharge.', 59.0, null, 30, 'Maison', 0],
      ['Mug isotherme', 'Garde vos boissons chaudes 6 h et froides 12 h. Contenance 450 ml.', 29.0, 22.0, 40, 'Maison', 0],
      ['Ballon de football', 'Ballon taille 5, cousu main, idéal pour l\'entraînement et le match.', 65.0, null, 18, 'Sport', 1],
      ['Tapis de yoga', 'Tapis antidérapant de 6 mm avec sangle de transport.', 79.0, null, 0, 'Sport', 0],
    ];
    for (final p in produits) {
      batch.insert('produits', {
        'nom': p[0],
        'description': p[1],
        'prix': p[2],
        'prix_promo': p[3],
        'stock': p[4],
        'categorie': p[5],
        'vedette': p[6],
      });
    }

    // --- Coupons ---
    batch.insert('coupons', {'code': 'BIENVENUE10', 'pourcentage': 10, 'actif': 1});
    batch.insert('coupons', {'code': 'SUP4DEV20', 'pourcentage': 20, 'actif': 1});
    batch.insert('coupons', {'code': 'ETE2026', 'pourcentage': 30, 'actif': 0}); // expiré

    await batch.commit(noResult: true);
  }
}
