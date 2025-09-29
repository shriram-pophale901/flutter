import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase {
  Future<Database> createDB() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), "TodoDB.db"),
      version: 3,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE Todo(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          date TEXT
          )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
         
          db.execute('CREATE TABLE IF NOT EXISTS Todo_new (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT)');
          db.execute('INSERT INTO Todo_new (id, title, description, date) SELECT id, title, description, date FROM Todo');
          db.execute('DROP TABLE IF EXISTS Todo');
          db.execute('ALTER TABLE Todo_new RENAME TO Todo');
        }
      },
    );
    return db;
  }

  //Get Data
  Future<List<Map>> getTodoItems() async {
    Database localDb = await createDB();
    List<Map> list = await localDb.query("Todo");
    return list;
  }

  void insertTodoItem(Map<String, dynamic> obj) async {
    Database localdb = await createDB();
    await localdb.insert(
      "Todo",
      obj,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Uptate data

  Future<void> updateTodoItem(Map<String, dynamic> obj) async {
    Database localDb = await createDB();
    localDb.update("Todo", obj, where: "id=?", whereArgs: [obj['id']]);
  }

  ///DELETE DATA
  Future<void> deleteTodoItem(int index) async {
    Database db = await createDB();
    await db.delete("Todo", where: "id=?", whereArgs: [index]);
  }


}
