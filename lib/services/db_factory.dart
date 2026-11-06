// lib/services/db_factory.dart
// Choisit automatiquement la bonne version de SQLite :
// - Android / iOS : sqflite normal
// - Web (Chrome)  : sqflite_common_ffi_web
export 'db_factory_mobile.dart' if (dart.library.js_interop) 'db_factory_web.dart';
