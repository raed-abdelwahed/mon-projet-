// lib/models/coupon.dart

/// Un code de réduction (ex : BIENVENUE10 = -10 %).
class Coupon {
  final int? id;
  final String code;
  final int pourcentage;
  final bool actif;

  const Coupon({
    this.id,
    required this.code,
    required this.pourcentage,
    this.actif = true,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'pourcentage': pourcentage,
        'actif': actif ? 1 : 0,
      };

  factory Coupon.fromMap(Map<String, Object?> map) => Coupon(
        id: map['id'] as int?,
        code: map['code'] as String,
        pourcentage: map['pourcentage'] as int,
        actif: (map['actif'] as int) == 1,
      );
}
