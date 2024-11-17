import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wird/models/rosary.dart';
import 'package:wird/models/serie.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rosary_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rosaries(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE series(
        id INTEGER PRIMARY KEY,
        rosaryId INTEGER,
        title TEXT,
        count INTEGER,
        FOREIGN KEY(rosaryId) REFERENCES rosaries(id)
      )
      ''');
  }

  Future<int> insertRosary(Rosary rosary) async {
    Database db = await instance.database;
    return await db.insert('rosaries', rosary.toMap());
  }

  Future<int> insertSerie(Serie serie, int rosary) async {
    Database db = await instance.database;
    serie.rosaryId = rosary;
    print(serie);
    return await db.insert('series', serie.toMap());
  }

  Future<int> updateSerie(Serie newserie) async {
    Database db = await instance.database;
    return await db.update(
      'series',
      newserie.toMap(),
      where: 'id = ?',
      whereArgs: [newserie.id],
    );
  }

  Future<int> updateRosary(Rosary rosary) async {
    Database db = await instance.database;
    return await db.update(
      'rosaries',
      rosary.toMap(),
      where: 'id = ?',
      whereArgs: [rosary.id],
    );
  }

  Future<int> deleteSeriesByRosary(int rosary) async {
    Database db = await instance.database;
    return await db.delete(
      'series',
      where: 'rosaryId = ?',
      whereArgs: [rosary],
    );
  }

  Future<int> deleteRosary(int rosary) async {
    Database db = await instance.database;
    return await db.delete(
      'rosaries',
      where: 'id = ?',
      whereArgs: [rosary],
    );
  }

  Future<int> deleteSerie(int serie) async {
    Database db = await instance.database;
    return await db.delete(
      'series',
      where: 'id = ?',
      whereArgs: [serie],
    );
  }

  Future<List<Serie>> getSeriesByRosaryId(int rosaryId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'series',
      where: 'rosaryId = ?',
      whereArgs: [rosaryId],
    );
    return List.generate(maps.length, (i) {
      return Serie.fromMap(maps[i]);
    });
  }

  Future<List<Rosary>> getRosaries() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('rosaries');
    return List.generate(maps.length, (i) {
      return Rosary.fromMap(maps[i]);
    });
  }

  Future<List<Rosary>> getRosary(int rosaryId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'rosaries',
      where: 'id = ?',
      whereArgs: [rosaryId],
    );
    return List.generate(maps.length, (i) {
      return Rosary.fromMap(maps[i]);
    });
  }

  Future<List<Serie>> getSeries() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('series');
    return List.generate(maps.length, (i) {
      return Serie.fromMap(maps[i]);
    });
  }
}
