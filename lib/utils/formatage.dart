// lib/utils/formatage.dart
import 'package:intl/intl.dart';

/// Affiche un prix en dinars tunisiens : 129.00 DT
String formatPrix(double montant) => '${montant.toStringAsFixed(2)} DT';

/// Affiche une date : 04/11/2026 20:30
String formatDate(DateTime date) => DateFormat('dd/MM/yyyy HH:mm').format(date);
