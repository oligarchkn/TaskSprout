// Реалізація ініціалізації фабрики БД для web.
//
// Цей файл підключається лише через умовний імпорт на web
// (умова `dart.library.html`) і НІКОЛИ не компілюється на нативних платформах.
//
// Використовує sqflite_common_ffi_web: SQLite через WASM з персистентним
// зберіганням у IndexedDB (дані переживають перезавантаження сторінки/додатку).
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> configureDatabaseFactory() async {
  // Підміняємо стандартну фабрику на web-реалізацію.
  // useImplicitByteBuffer: true пришвидшує роботу з WASM-пам'яттю.
  databaseFactory = databaseFactoryFfiWeb;
  debugPrint('DB factory: sqflite_common_ffi_web (web)');
}
