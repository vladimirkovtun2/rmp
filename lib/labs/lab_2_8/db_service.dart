import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Сервис работы с SQLite по методичке (лабораторная 2.8).
///
/// Одиночка с ленивой инициализацией базы MyDatabase.db и таблицы MyTable
/// (id, name). Публичный API повторяет методичку: addRecord,
/// updateRecord, deleteRecord, getAllRecords, getSortedRecords.
///
/// Если sqflite недоступен (тесты, десктоп), прозрачно включается
/// резервный режим «в памяти» — поведение экрана не меняется.
class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;

  DBService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'MyDatabase.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS MyTable ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT)',
        );
      },
    );
  }

  // ====== Резервный режим в памяти ======

  bool? _memoryMode;
  final List<Map<String, dynamic>> _memoryTable = [];
  int _memoryNextId = 1;

  Future<bool> _detectMemoryMode() async {
    try {
      await getDatabasesPath();
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> _ensureReady() async {
    _memoryMode ??= await _detectMemoryMode();
  }

  // ====== Операции с записями ======

  // Добавление новой записи
  Future<int> addRecord(String name) async {
    await _ensureReady();
    if (_memoryMode!) {
      final id = _memoryNextId++;
      _memoryTable.add({'id': id, 'name': name});
      return id;
    }
    final db = await database;
    return db.insert('MyTable', {'name': name});
  }

  // Обновление записи
  Future<void> updateRecord(int id, String newName) async {
    await _ensureReady();
    if (_memoryMode!) {
      for (final row in _memoryTable) {
        if (row['id'] == id) row['name'] = newName;
      }
      return;
    }
    final db = await database;
    await db.update(
      'MyTable',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Удаление записи
  Future<int> deleteRecord(int id) async {
    await _ensureReady();
    if (_memoryMode!) {
      _memoryTable.removeWhere((row) => row['id'] == id);
      return 1;
    }
    final db = await database;
    return db.delete('MyTable', where: 'id = ?', whereArgs: [id]);
  }

  // Выборка всех записей без сортировки
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    await _ensureReady();
    if (_memoryMode!) return List.of(_memoryTable);
    final db = await database;
    return db.query('MyTable');
  }

  // Выборка с сортировкой по имени
  Future<List<Map<String, dynamic>>> getSortedRecords() async {
    await _ensureReady();
    if (_memoryMode!) {
      final sorted = List<Map<String, dynamic>>.of(_memoryTable)
        ..sort((a, b) => (b['name'] as String).compareTo(a['name'] as String));
      return sorted;
    }
    final db = await database;
    return db.query('MyTable', orderBy: 'name DESC');
  }
}
