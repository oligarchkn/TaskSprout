import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasksprout.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    debugPrint('Opening database at: $path');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerTypeNullable = 'INTEGER';

    // Таблиця categories
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType UNIQUE,
        icon $textTypeNullable,
        color $textTypeNullable
      )
    ''');

    // Таблиця tasks
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textTypeNullable,
        category_id $integerTypeNullable,
        priority $integerType DEFAULT 0,
        due_date $textTypeNullable,
        is_completed $integerType DEFAULT 0,
        is_archived $integerType DEFAULT 0,
        is_focused $integerType DEFAULT 0,
        completed_at $textTypeNullable,
        created_at $textType,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Таблиця notes
    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        content $textType,
        created_at $textType,
        updated_at $textTypeNullable
      )
    ''');

    // Додаємо дефолтні категорії
    await _insertDefaultCategories(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Додаємо таблицю notes при оновленні з версії 1 до 2
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';

      await db.execute('''
        CREATE TABLE notes (
          id $idType,
          content $textType,
          created_at $textType,
          updated_at $textTypeNullable
        )
      ''');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Робота', 'icon': '💼', 'color': '#2196F3'},
      {'name': 'Особисте', 'icon': '👤', 'color': '#4CAF50'},
      {'name': 'Покупки', 'icon': '🛒', 'color': '#FF9800'},
      {'name': 'Здоров\'я', 'icon': '🏥', 'color': '#F44336'},
      {'name': 'Інше', 'icon': '📌', 'color': '#9E9E9E'},
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // ==================== TASKS CRUD ====================

  Future<int> createTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    return id;
  }

  Future<Task?> readTask(int id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> readAllTasks() async {
    final db = await database;
    const orderBy = 'created_at DESC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> readTasksByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> readActiveTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'is_completed = ? AND is_archived = ?',
      whereArgs: [0, 0],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> readCompletedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'is_completed = ? AND is_archived = ?',
      whereArgs: [1, 0],
      orderBy: 'completed_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> readArchivedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'is_archived = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> readFocusedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'is_focused = ? AND is_completed = ? AND is_archived = ?',
      whereArgs: [1, 0, 0],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await database;
    return await db.delete('tasks');
  }

  // ==================== CATEGORIES CRUD ====================

  Future<int> createCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> readAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== UTILITY ====================

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasksprout.db');
    await databaseFactory.deleteDatabase(path);
  }

  // ==================== NOTES CRUD ====================

  Future<int> createNote(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return id;
  }

  Future<Note?> readNote(int id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Note>> readAllNotes() async {
    final db = await database;
    const orderBy = 'created_at DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    final db = await database;
    return await db.delete('notes');
  }
}
