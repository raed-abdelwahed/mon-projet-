// lib/services/coupon_service.dart
import '../models/coupon.dart';
import 'database_service.dart';

class CouponService {
  /// Renvoie le coupon s'il existe et qu'il est actif, sinon null.
  Future<Coupon?> trouverActif(String code) async {
    if (code.trim().isEmpty) return null;
    final db = await DatabaseService.instance.database;
    final lignes = await db.query(
      'coupons',
      where: 'UPPER(code) = ? AND actif = 1',
      whereArgs: [code.trim().toUpperCase()],
      limit: 1,
    );
    return lignes.isEmpty ? null : Coupon.fromMap(lignes.first);
  }
}
