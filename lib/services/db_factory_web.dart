// lib/services/db_factory_web.dart
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Sur le web (Chrome), on utilise la version WebAssembly de SQLite.
void configurerFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
