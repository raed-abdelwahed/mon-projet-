# SUP4 DEV E-Commerce

Application Flutter de vente en ligne avec un espace client et un espace admin.
Stockage local SQLite (sqflite), gestion d'état avec Provider, architecture MVC
(models / providers / services / views / widgets).

## Lancer le projet
```bash
flutter create .
flutter pub get
dart run sqflite_common_ffi_web:setup   # seulement pour lancer sur Chrome
flutter run
```

## Comptes de démonstration
| Rôle   | Email           | Mot de passe |
|--------|-----------------|--------------|
| Client | client@sup4.tn  | client123    |
| Admin  | admin@sup4.tn   | admin123     |

## Codes promo
- `BIENVENUE10` : -10 %
- `SUP4DEV20` : -20 %
- `ETE2026` : expiré (pour tester le refus)

## Paiement
Le paiement est **simulé**. Une carte qui se termine par `0000` est refusée.

## Fonctionnalités (étapes 1 à 4)
- Thème clair / sombre mémorisé
- Inscription, connexion, session gardée, rôles client / admin
- Boutique : recherche, filtre par catégorie, produits vedettes, promotions, rupture de stock
- Détail produit avec choix de la quantité
- Panier : quantités, suppression, code promo, totaux
- Commande : adresse, paiement simulé, mise à jour du stock (transaction SQLite)
- Historique des commandes avec détail
- Tests unitaires du panier + test widget

## Tests
```bash
flutter test
```
