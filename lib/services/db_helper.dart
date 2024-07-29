import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  Database? _db;

  DatabaseHelper._instance();
  final String materiasTable = "materia_table";
  final String mId = "id";
  final String mMateria = "materia";
  final String mNota = "nota";

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "materia.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => {
        db.execute(
            "CREATE TABLE $materiasTable($mId INTEGER PRIMARY KEY AUTOINCREMENT, $mMateria TEXT, $mNota INTEGER)")
      },
    );
  }

//Lista de Resultados
  Future<List<Map<String, dynamic>>> getMateriaMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(materiasTable);
    return result;
  }

  //Inseção de dados
  Future<int> insertMateria(Map<String, dynamic> materia) async {
    Database? db = await this.db;
    final int result = await db!.insert(materiasTable, materia);
    return result;
  }

  //Update dados
  Future<int> updateMateria(Map<String, dynamic> materia) async {
    Database? db = await this.db;
    final int result = await db!.update(materiasTable, materia,
        where: "$mId=?", whereArgs: [materia[mId]]);
    return result;
  }

  //Apagar dados
  Future<int> deleteMateria(int id) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(materiasTable, where: "$mId=?", whereArgs: [id]);
    return result;
  }
}
