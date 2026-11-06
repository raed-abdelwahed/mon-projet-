// lib/services/produit_service.dart
import '../models/produit.dart';
import 'database_service.dart';

/// Lecture des produits (le CRUD admin sera ajouté à l'étape 5).
class ProduitService {
  Future<List<Produit>> tous() async {
    final db = await DatabaseService.instance.database;
    final lignes = await db.query('produits', orderBy: 'nom ASC');
    return lignes.map(Produit.fromMap).toList();
  }

  Future<Produit?> parId(int id) async {
    final db = await DatabaseService.instance.database;
    final lignes = await db.query(
      'produits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return lignes.isEmpty ? null : Produit.fromMap(lignes.first);
  }
}
