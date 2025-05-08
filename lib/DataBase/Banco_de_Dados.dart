import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  Future<int> registerUser(String name, String email, String password) async {
    final database = await db;
    try {
      return await database.insert('users', {
        'name': name,
        'email': email,
        'password': password,
      });
    } catch (e) {
      return -1; // erro (e-mail já existe)
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final database = await db;
    final result = await database.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
