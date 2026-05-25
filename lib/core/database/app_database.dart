import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _db;

  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    print('Database opened!');
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'database.db');
    return openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
                '''
              ALTER TABLE users ADD COLUMN perfil TEXT
            '''
            );
          }
          if (oldVersion < 3) {
            await db.execute(
                '''
              ALTER TABLE users ADD COLUMN telefone TEXT
              ALTER TABLE users ADD COLUMN telefone_emergencia TEXT
              ALTER TABLE users ADD COLUMN cpf TEXT
              ALTER TABLE users ADD COLUMN observacao_medica TEXT
              ALTER TABLE users ADD COLUMN data_nascimento TEXT
              
            '''
            );
          }
        }
    );
  }
}