// Реалізація ініціалізації фабрики БД для нативних платформ.
//
// Цей файл підключається лише через умовний імпорт на нативних платформах
// (Android/iOS/Windows/Linux/macOS) і НІКОЛИ не компілюється на web,
// тому дозволено використовувати dart:io та dart:ffi (через sqflite_common_ffi).
//
// - Android / iOS: стандартна плагінна фабрика sqflite (нічого не робимо).
// - Windows / Linux / macOS (desktop): вмикаємо sqflite_common_ffi,
//   оскільки нативний плагін sqflite там недоступний.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

Future<void> configureDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // На desktop немає нативного плагіну sqflite — вмикаємо FFI-реалізацію.
    ffi.sqfliteFfiInit();
    databaseFactory = ffi.databaseFactoryFfi;
    debugPrint('DB factory: sqflite_common_ffi (desktop)');
  } else {
    // Android / iOS — стандартна плагінна фабрика вже підключена.
    debugPrint('DB factory: default sqflite (Android/iOS)');
  }
}
