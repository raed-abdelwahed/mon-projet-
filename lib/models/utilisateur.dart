// lib/models/utilisateur.dart

/// Un utilisateur de l'application : client ou administrateur.
class Utilisateur {
  final int? id;
  final String nom;
  final String email;
  final String motDePasse; // toujours stocké haché (SHA-256)
  final String role; // 'client' ou 'admin'

  const Utilisateur({
    this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    this.role = 'client',
  });

  bool get estAdmin => role == 'admin';

  Map<String, Object?> toMap() => {
        'id': id,
        'nom': nom,
        'email': email,
        'mot_de_passe': motDePasse,
        'role': role,
      };

  factory Utilisateur.fromMap(Map<String, Object?> map) => Utilisateur(
        id: map['id'] as int?,
        nom: map['nom'] as String,
        email: map['email'] as String,
        motDePasse: map['mot_de_passe'] as String,
        role: map['role'] as String,
      );
}
