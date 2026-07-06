// Платформно-нейтральний фасад для ініціалізації фабрики бази даних.
//
// Реальна реалізація обирається умовним імпортом (див. нижче):
//  - web:     lib/database/database_factory_web.dart   (sqflite_common_ffi_web)
//  - нативно: lib/database/database_factory_io.dart     (sqflite_common_ffi для desktop)
// Нативні платформи (Android/iOS) використовують стандартну фабрику sqflite.
import 'database_factory_io.dart'
    if (dart.library.html) 'database_factory_web.dart';

/// Ініціалізує фабрику БД відповідно до платформи та повертає її.
///
/// Має викликатися один раз при старті додатку (до першого звернення до БД).
Future<void> initDatabaseFactory() async {
  await configureDatabaseFactory();
}
