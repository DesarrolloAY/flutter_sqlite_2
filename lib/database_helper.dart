import 'package:flutter_sqlite_2/libros.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bdlibros.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE libros (id INTEGER PRIMARY KEY AUTOINCREMENT, tituloLibro TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertLibro(Libro item) async {
    final db = await database;
    await db.insert(
      'libros',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Libro>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('libros');
    return List.generate(maps.length, (i) {
      return Libro(id: maps[i]['id'], tituloLibro: maps[i]['tituloLibro']);
    });
  }

  Future<int> eliminar(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _initDatabase();
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> actualizar(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final db = await _initDatabase();
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
