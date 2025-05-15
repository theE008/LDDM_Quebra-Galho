import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class Banco_de_dados {
  static final Banco_de_dados _instance = Banco_de_dados._internal();
  factory Banco_de_dados() => _instance;
  Banco_de_dados._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'quebra_galho.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE areas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            area REAL,
            titulo TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE pontos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            area_id INTEGER,
            latitude REAL,
            longitude REAL,
            altitude REAL,
            accuracy REAL,
            speed REAL,
            speedAccuracy REAL,
            heading REAL,
            timestamp TEXT,
            FOREIGN KEY(area_id) REFERENCES areas(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
         await db.execute('ALTER TABLE areas ADD COLUMN titulo TEXT');
        }
      },
    );
  }

  Future<int> salvarArea(double area) async {
    final dbClient = await db;
    return await dbClient.insert('areas', {'area': area});
  }

  Future<void> salvarPontos(int areaId, List<Position> pontos) async {
    final dbClient = await db;
    for (final ponto in pontos) {
      await dbClient.insert('pontos', {
        'area_id': areaId,
        'latitude': ponto.latitude,
        'longitude': ponto.longitude,
        'altitude': ponto.altitude,
        'accuracy': ponto.accuracy,
        'speed': ponto.speed,
        'speedAccuracy': ponto.speedAccuracy,
        'heading': ponto.heading,
        'timestamp': ponto.timestamp?.toIso8601String() ?? '',
      });
    }
  }

  Future<List<Map<String, dynamic>>> buscarAreas() async {
    final dbClient = await db;
    return await dbClient.query('areas');
  }

  Future<List<Map<String, dynamic>>> buscarPontos(int areaId) async {
    final dbClient = await db;
    return await dbClient.query('pontos', where: 'area_id = ?', whereArgs: [areaId]);
  }

  Future<void> deletarArea(int areaId) async {
    final dbClient = await db;
    await dbClient.delete('areas', where: 'id = ?', whereArgs: [areaId]);
  }

  Future<int> salvarAreaComTitulo(double area, String titulo) async {
  final dbClient = await db;
  return await dbClient.insert('areas', {
    'area': area,
    'titulo': titulo,
  });
}
Future<void> atualizarTituloArea(int areaId, String novoTitulo) async {
  final dbClient = await db;
  await dbClient.update(
    'areas',
    {'titulo': novoTitulo},
    where: 'id = ?',
    whereArgs: [areaId],
  );
}
}