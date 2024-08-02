import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/materia_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  Database? _db;

  DatabaseHelper._instance();

  final String materiasTable = "materia_table";
  final String mId = "id";
  final String mDisciplina = "disciplina";
  final String mNotas = "notas";
  final String mIsSemestral = "isSemestral";

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "materia.db");
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) {
        _createDb(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS $materiasTable');
          _createDb(db);
        }
      },
    );
  }

  void _createDb(Database db) {
    db.execute('''
      CREATE TABLE $materiasTable(
        $mId INTEGER PRIMARY KEY AUTOINCREMENT,
        $mDisciplina TEXT,
        $mNotas TEXT,
        $mIsSemestral INTEGER
      )
    ''');
  }

  Future<int> insertMateria(MateriaModel materia) async {
    Database? db = await this.db;
    final materiaMap = materia.toMap()..remove('id');
    final int result = await db!.insert(materiasTable, materiaMap);
    return result;
  }

  Future<int> updateMateria(Map<String, dynamic> materia) async {
    Database? db = await this.db;
    final int result = await db!.update(materiasTable, materia,
        where: "$mId = ?", whereArgs: [materia[mId]]);
    return result;
  }

  Future<int> deleteMateria(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
        materiasTable, where: "$mId = ?", whereArgs: [id]);
    return result;
  }

  Future<List<MateriaModel>> getMateriaList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(materiasTable);
    return result.map((map) => MateriaModel.fromMap(map)).toList();
  }
}
